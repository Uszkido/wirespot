package com.wirespot.app.vpn

import android.content.Context
import android.net.VpnService

class WireGuardTunnelManager(private val context: Context) {
    private val preferences = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
    private val importedConfigs = mutableMapOf<String, String>()
    private val logBuffer = ArrayDeque<String>()
    private var state = WireGuardTunnelState.DISCONNECTED
    private var activeTunnelName: String? = preferences.getString(KEY_ACTIVE_TUNNEL, null)
    private var message: String? = null

    fun importConfig(name: String, config: String) {
        require(name.isNotBlank()) { "Tunnel name is required." }
        require(config.contains("[Interface]")) { "WireGuard config is missing [Interface]." }
        require(config.contains("[Peer]")) { "WireGuard config is missing [Peer]." }

        importedConfigs[name] = config
        preferences.edit().putString(KEY_ACTIVE_TUNNEL, name).apply()
        activeTunnelName = name
        message = "Tunnel config imported."
        appendLog(message!!)
    }

    fun connect(name: String): Map<String, Any?> {
        val config = importedConfigs[name]
            ?: throw IllegalArgumentException("No imported WireGuard config found for $name.")

        activeTunnelName = name
        preferences.edit().putString(KEY_ACTIVE_TUNNEL, name).apply()

        val permissionIntent = VpnService.prepare(context)
        if (permissionIntent != null) {
            state = WireGuardTunnelState.DISCONNECTED
            message = "Android VPN permission is required before connecting."
            appendLog(message!!)
            return statusMap(extra = mapOf("permissionRequired" to true))
        }

        state = WireGuardTunnelState.ERROR
        message = "Official WireGuard backend is not linked yet."
        appendLog("Connect requested for $name (${config.length} config bytes). $message")
        throw WireGuardBackendUnavailableException(message!!)
    }

    fun disconnect(): Map<String, Any?> {
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

    companion object {
        private const val PREFERENCES_NAME = "wirespot_wireguard"
        private const val KEY_ACTIVE_TUNNEL = "active_tunnel"
        private const val MAX_LOG_LINES = 200
    }
}

class WireGuardBackendUnavailableException(message: String) : IllegalStateException(message)
