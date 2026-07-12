package com.wirespot.app.vpn

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WireGuardChannelHandler(
    activity: Activity,
    private val binaryMessenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private val manager = WireGuardTunnelManager(activity)
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    fun attach() {
        methodChannel = MethodChannel(binaryMessenger, METHOD_CHANNEL).also {
            it.setMethodCallHandler(this)
        }
        eventChannel = EventChannel(binaryMessenger, STATUS_CHANNEL).also {
            it.setStreamHandler(this)
        }
    }

    fun detach() {
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        methodChannel = null
        eventChannel = null
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "importConfig" -> {
                    val name = call.argument<String>("name").orEmpty()
                    val config = call.argument<String>("config").orEmpty()
                    manager.importConfig(name, config)
                    emitStatus()
                    result.success(null)
                }
                "connect" -> {
                    val name = call.argument<String>("name").orEmpty()
                    val status = manager.connect(name)
                    emitStatus(status)
                    result.success(null)
                }
                "requestPermission" -> {
                    val status = manager.requestPermission()
                    emitStatus(status)
                    result.success(null)
                }
                "disconnect" -> {
                    val status = manager.disconnect()
                    emitStatus(status)
                    result.success(null)
                }
                "status" -> result.success(manager.statusMap())
                "statistics" -> result.success(manager.statisticsMap())
                "logs" -> result.success(manager.logs())
                else -> result.notImplemented()
            }
        } catch (error: IllegalArgumentException) {
            result.error("INVALID_ARGUMENT", error.message, null)
        } catch (error: Exception) {
            result.error("WIREGUARD_ERROR", error.message, null)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        emitStatus()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun emitStatus(status: Map<String, Any?> = manager.statusMap()) {
        eventSink?.success(status)
    }

    companion object {
        private const val METHOD_CHANNEL = "com.wirespot.app/wireguard"
        private const val STATUS_CHANNEL = "com.wirespot.app/wireguard_status"
    }
}
