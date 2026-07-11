package com.wirespot.app.vpn

import android.app.Activity
import android.content.Context
import android.net.VpnService
import com.wireguard.android.backend.GoBackend
import com.wireguard.android.backend.Tunnel
import com.wireguard.config.Config
import java.io.ByteArrayInputStream

class WireGuardTunnelManager(private val activity: Activity) {
    private val preferences = activity.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
    private val backend by lazy { GoBackend(activity.applicationContext) }
    private val importedConfigs = mutableMapOf<String, String>()
    private val logBuffer = ArrayDeque<String>()
    private var state = WireGuardTunnelState.DISCONNECTED
    private var activeTunnelName: String? = preferences.getString(KEY_ACTIVE_TUNNEL, null)
    private var activeTunnel: WireSpotTunnel? = null
    private var message: String? = null

    fun importConfig(name: String, config: String) {
        val tunnelName = normalizeTunnelName(name)
        require(config.contains("[Interface]")) { "WireGuard config is missing [Interface]." }
        require(config.contains("[Peer]")) { "WireGuard config is missing [Peer]." }
        parseConfig(config)

        importedConfigs[tunnelName] = config
        preferences.edit()
            .putString(KEY_ACTIVE_TUNNEL, tunnelName)
            .apply()
        activeTunnelName = tunnelName
        message = "Tunnel config imported."
        appendLog(message!!)
    }

    fun connect(name: String): Map<String, Any?> {
        val tunnelName = normalizeTunnelName(name)
        val rawConfig = importedConfigs[tunnelName]
            ?: throw IllegalArgumentException("No imported WireGuard config found for $tunnelName.")

        activeTunnelName = tunnelName
        preferences.edit().putString(KEY_ACTIVE_TUNNEL, tunnelName).apply()

        val permissionIntent = VpnService.prepare(activity)
        if (permissionIntent != null) {
            state = WireGuardTunnelState.DISCONNECTED
            message = "Android VPN permission is required before connecting."
            appendLog(message!!)
            activity.startActivity(permissionIntent)
            return statusMap(extra = mapOf("permissionRequired" to true))
        }

        return try {
            state = WireGuardTunnelState.CONNECTING
            message = "Connecting tunnel."
            appendLog("Connect requested for $tunnelName (${rawConfig.length} config bytes).")
            val tunnel = activeTunnel?.takeIf { it.tunnelName == tunnelName } ?: WireSpotTunnel(tunnelName)
            val nextState = backend.setState(tunnel, Tunnel.State.UP, parseConfig(rawConfig))
            activeTunnel = tunnel
            state = nextState.toWireSpotState()
            message = "Tunnel ${state.platformName}."
            appendLog(message!!)
            statusMap()
        } catch (error: Exception) {
            state = WireGuardTunnelState.ERROR
            message = error.message ?: "Could not connect WireGuard tunnel."
            appendLog(message!!)
            throw error
        }
    }

    fun disconnect(): Map<String, Any?> {
        val tunnel = activeTunnel
        if (tunnel != null) {
            state = WireGuardTunnelState.DISCONNECTING
            backend.setState(tunnel, Tunnel.State.DOWN, null)
        }
        activeTunnel = null
        state = WireGuardTunnelState.DISCONNECTED
        message = "Tunnel disconnected."
        appendLog(message!!)
        return statusMap()
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
            val statistics = backend.getStatistics(tunnel)
            val latestHandshakeAtMillis = statistics.peers()
                .mapNotNull { peer -> statistics.peer(peer)?.latestHandshakeEpochMillis() }
                .maxOrNull()
            return mapOf(
                "rxBytes" to statistics.totalRx(),
                "txBytes" to statistics.totalTx(),
                "latestHandshakeAtMillis" to latestHandshakeAtMillis,
            )
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
            state = newState.toWireSpotState()
            message = "Tunnel ${state.platformName}."
            appendLog(message!!)
        }
    }

    companion object {
        private const val PREFERENCES_NAME = "wirespot_wireguard"
        private const val KEY_ACTIVE_TUNNEL = "active_tunnel"
        private const val MAX_LOG_LINES = 200
    }
}
