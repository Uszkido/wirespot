package com.wirespot.app.platform

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PrinterChannelHandler(
    private val binaryMessenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private var methodChannel: MethodChannel? = null

    fun attach() {
        methodChannel = MethodChannel(binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler(this)
        }
    }

    fun detach() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pairedBluetoothPrinters" -> result.success(emptyList<Map<String, String>>())
            "printText" -> result.error(
                "PRINTER_BACKEND_UNAVAILABLE",
                "Bluetooth ESC/POS transport is not implemented yet.",
                null,
            )
            else -> result.notImplemented()
        }
    }

    companion object {
        private const val CHANNEL = "com.wirespot.app/printer"
    }
}
