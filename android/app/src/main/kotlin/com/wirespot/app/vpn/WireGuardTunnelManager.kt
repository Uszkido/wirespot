package com.wirespot.app.vpn

import android.app.Activity
import android.content.Context
import android.net.VpnService
import android.os.Handler
import android.os.Looper
import com.wireguard.android.backend.GoBackend
import com.wireguard.android.backend.Tunnel
import com.wireguard.config.Config
import java.io.ByteArrayInputStream
import java.util.concurrent.Executors

class WireGuardTunnelManager(private val activity: Activity) {
    private val preferences = activity.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
    private val backend by lazy { GoBackend(activity.applicationContext) }
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private val importedConfigs = mutableMapOf<String, String>()
    private val logBuffer = ArrayDeque<String>()
    private var state = WireGuardTunnelState.DISCONNECTED
    private var activeTunnelName: String? = preferences.getString(KEY_ACTIVE_TUNNEL, null)
    private var activeTunnel: WireSpotTunnel? = null
    private var pendingPermissionTunnelName: String? = null
    private var message: String? = null

    fun importConfig(name: String, config: String) {
        val tunnelName = normalizeTunnelName(name)
        require(config.lowercase().contains("[interface]")) { "WireGuard config is missing [Interface]." }
        require(config.lowercase().contains("[peer]")) { "WireGuard config is missing [Peer]." }
        parseConfig(config)

        importedConfigs[tunnelName] = config
        preferences.edit()
            .putString(KEY_ACTIVE_TUNNEL, tunnelName)
            .putString(KEY_CONFIG_PREFIX + tunnelName, config)
            .apply()
        activeTunnelName = tunnelName
        message = "Tunnel config imported."
        appendLog(message!!)
    }

    fun connect(name: String, callback: (Map<String, Any?>, Exception?) -> Unit) {
        val tunnelName = normalizeTunnelName(name)
        var rawConfig = importedConfigs[tunnelName]
        if (rawConfig == null) {
            rawConfig = preferences.getString(KEY_CONFIG_PREFIX + tunnelName, null)
            if (rawConfig != null) {
                importedConfigs[tunnelName] = rawConfig
            }
        }
        if (rawConfig == null) {
            callback(emptyMap(), IllegalArgumentException("No imported WireGuard config found for $tunnelName."))
            return
        }

        activeTunnelName = tunnelName
        preferences.edit().putString(KEY_ACTIVE_TUNNEL, tunnelName).apply()

        val permissionIntent = VpnService.prepare(activity)
        if (permissionIntent != null) {
            state = WireGuardTunnelState.DISCONNECTED
            message = "Android VPN permission is required before connecting."
            appendLog(message!!)
            pendingPermissionTunnelName = tunnelName
            activity.startActivityForResult(permissionIntent, VPN_PERMISSION_REQUEST_CODE)
            callback(statusMap(extra = mapOf("permissionRequired" to true)), null)
            return
        }

        state = WireGuardTunnelState.CONNECTING
        message = "Connecting tunnel."
        appendLog("Connect requested for $tunnelName (${rawConfig.length} config bytes).")

        executor.execute {
            try {
                val tunnel = activeTunnel?.takeIf { it.tunnelName == tunnelName } ?: WireSpotTunnel(tunnelName)
                val parsedConfig = parseConfig(rawConfig)
                val nextState = backend.setState(tunnel, Tunnel.State.UP, parsedConfig)
                activeTunnel = tunnel
                mainHandler.post {
                    state = nextState.toWireSpotState()
                    message = "Tunnel ${state.platformName}."
                    appendLog(message!!)
                    callback(statusMap(), null)
                }
            } catch (error: Exception) {
                mainHandler.post {
                    state = WireGuardTunnelState.ERROR
                    val detailMsg = error.message ?: error.localizedMessage ?: "Failed to connect WireGuard tunnel (${error.javaClass.simpleName})"
                    message = detailMsg
                    appendLog("ERROR: $detailMsg")
                    callback(emptyMap(), Exception(detailMsg, error))
                }
            }
        }
    }

    fun requestPermission(): Map<String, Any?> {
        val permissionIntent = VpnService.prepare(activity)
        return if (permissionIntent != null) {
            message = "Android VPN permission requested."
            appendLog(message!!)
            activity.startActivityForResult(permissionIntent, VPN_PERMISSION_REQUEST_CODE)
            statusMap(extra = mapOf("permissionRequired" to true))
        } else {
            message = "Android VPN permission already granted."
            appendLog(message!!)
            statusMap(extra = mapOf("permissionRequired" to false))
        }
    }

    fun onPermissionResult(resultCode: Int, callback: ((Map<String, Any?>?, Exception?) -> Unit)? = null) {
        if (resultCode != Activity.RESULT_OK) {
            pendingPermissionTunnelName = null
            state = WireGuardTunnelState.DISCONNECTED
            message = "Android VPN permission was not granted."
            appendLog(message!!)
            callback?.invoke(statusMap(extra = mapOf("permissionRequired" to true)), null)
            return
        }

        val tunnelName = pendingPermissionTunnelName
        pendingPermissionTunnelName = null
        message = "Android VPN permission granted."
        appendLog(message!!)
        if (tunnelName != null) {
            connect(tunnelName) { status, error ->
                callback?.invoke(status, error)
            }
        } else {
            callback?.invoke(statusMap(extra = mapOf("permissionRequired" to false)), null)
        }
    }

    fun disconnect(callback: (Map<String, Any?>, Exception?) -> Unit) {
        val tunnel = activeTunnel
        if (tunnel == null) {
            state = WireGuardTunnelState.DISCONNECTED
            message = "Tunnel disconnected."
            appendLog(message!!)
            callback(statusMap(), null)
            return
        }

        state = WireGuardTunnelState.DISCONNECTING
        executor.execute {
            try {
                backend.setState(tunnel, Tunnel.State.DOWN, null)
                activeTunnel = null
                mainHandler.post {
                    state = WireGuardTunnelState.DISCONNECTED
                    message = "Tunnel disconnected."
                    appendLog(message!!)
                    callback(statusMap(), null)
                }
            } catch (error: Exception) {
                mainHandler.post {
                    activeTunnel = null
                    state = WireGuardTunnelState.DISCONNECTED
                    message = "Tunnel disconnected."
                    appendLog(message!!)
                    callback(statusMap(), null)
                }
            }
        }
    }

    fun statusMap(extra: Map<String, Any?> = emptyMap()): Map<String, Any?> {
        return buildMap {
            put("state", state.platformName)
            put("tunnelName", activeTunnelName)
            put("message", message)
            putAll(extra)
        }
    }

    fun statisticsMap(): Map<String, Any?> {
        val tunnel = activeTunnel
        if (tunnel != null) {
            return try {
                val statistics = backend.getStatistics(tunnel)
                val latestHandshakeAtMillis = statistics.peers()
                    .mapNotNull { peer -> statistics.peer(peer)?.latestHandshakeEpochMillis() }
                    .maxOrNull()
                mapOf(
                    "rxBytes" to statistics.totalRx(),
                    "txBytes" to statistics.totalTx(),
                    "latestHandshakeAtMillis" to latestHandshakeAtMillis,
                )
            } catch (e: Exception) {
                mapOf("rxBytes" to 0L, "txBytes" to 0L, "latestHandshakeAtMillis" to null)
            }
        }
        return mapOf(
            "rxBytes" to 0L,
            "txBytes" to 0L,
            "latestHandshakeAtMillis" to null,
        )
    }

    fun logs(): List<String> = logBuffer.toList()

    private fun appendLog(entry: String) {
        if (logBuffer.size >= MAX_LOG_LINES) {
            logBuffer.removeFirst()
        }
        logBuffer.addLast("${System.currentTimeMillis()}: $entry")
    }

    private fun parseConfig(config: String): Config {
        return Config.parse(ByteArrayInputStream(config.toByteArray(Charsets.UTF_8)))
    }

    private fun normalizeTunnelName(name: String): String {
        val normalized = name
            .trim()
            .replace(Regex("[^A-Za-z0-9_=+.-]"), "_")
            .take(Tunnel.NAME_MAX_LENGTH)
        require(normalized.isNotBlank()) { "Tunnel name is required." }
        require(!Tunnel.isNameInvalid(normalized)) { "Tunnel name contains unsupported characters." }
        return normalized
    }

    private fun Tunnel.State.toWireSpotState(): WireGuardTunnelState {
        return when (this) {
            Tunnel.State.UP -> WireGuardTunnelState.CONNECTED
            Tunnel.State.DOWN -> WireGuardTunnelState.DISCONNECTED
            Tunnel.State.TOGGLE -> state
        }
    }

    private inner class WireSpotTunnel(val tunnelName: String) : Tunnel {
        override fun getName(): String = tunnelName

        override fun onStateChange(newState: Tunnel.State) {
            mainHandler.post {
                state = newState.toWireSpotState()
                message = "Tunnel ${state.platformName}."
                appendLog(message!!)
            }
        }
    }

    companion object {
        const val VPN_PERMISSION_REQUEST_CODE = 7012
        private const val PREFERENCES_NAME = "wirespot_wireguard"
        private const val KEY_ACTIVE_TUNNEL = "active_tunnel"
        private const val KEY_CONFIG_PREFIX = "tunnel_config_"
        private const val MAX_LOG_LINES = 200
    }
}
