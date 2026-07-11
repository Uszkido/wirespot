package com.wirespot.app.vpn

enum class WireGuardTunnelState(val platformName: String) {
    DISCONNECTED("disconnected"),
    CONNECTING("connecting"),
    CONNECTED("connected"),
    DISCONNECTING("disconnecting"),
    ERROR("error"),
}
