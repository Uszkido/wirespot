package com.wirespot.app.platform

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.nio.charset.Charset
import java.util.UUID

class PrinterChannelHandler(
    private val activity: Activity,
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
            "pairedBluetoothPrinters" -> pairedBluetoothPrinters(result)
            "printText" -> printText(call, result)
            else -> result.notImplemented()
        }
    }

    private fun pairedBluetoothPrinters(result: MethodChannel.Result) {
        val adapter = bluetoothAdapter()
        if (adapter == null) {
            result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth is not available on this device.", null)
            return
        }
        if (!adapter.isEnabled) {
            result.error("BLUETOOTH_DISABLED", "Turn on Bluetooth and try again.", null)
            return
        }
        if (!ensureBluetoothPermission(result)) {
            return
        }

        val devices = adapter.bondedDevices
            .map { device ->
                mapOf(
                    "name" to (device.name ?: "Bluetooth printer"),
                    "address" to device.address,
                )
            }
            .sortedBy { it["name"] ?: "" }
        result.success(devices)
    }

    private fun printText(call: MethodCall, result: MethodChannel.Result) {
        val address = call.argument<String>("address").orEmpty()
        val text = call.argument<String>("text").orEmpty()
        if (address.isBlank()) {
            result.error("INVALID_PRINTER", "Bluetooth printer address is required.", null)
            return
        }
        if (text.isBlank()) {
            result.error("EMPTY_PRINT_JOB", "Nothing was sent to the printer.", null)
            return
        }

        val adapter = bluetoothAdapter()
        if (adapter == null) {
            result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth is not available on this device.", null)
            return
        }
        if (!adapter.isEnabled) {
            result.error("BLUETOOTH_DISABLED", "Turn on Bluetooth and try again.", null)
            return
        }
        if (!ensureBluetoothPermission(result)) {
            return
        }

        try {
            val device = adapter.getRemoteDevice(address)
            Thread {
                try {
                    adapter.cancelDiscovery()
                    writeEscPosText(device, text)
                    activity.runOnUiThread {
                        result.success(
                            mapOf(
                                "success" to true,
                                "message" to "Receipt sent to ${device.name ?: address}.",
                            ),
                        )
                    }
                } catch (error: SecurityException) {
                    activity.runOnUiThread {
                        result.error(
                            "BLUETOOTH_PERMISSION_REQUIRED",
                            "Bluetooth permission is required.",
                            null,
                        )
                    }
                } catch (error: IOException) {
                    activity.runOnUiThread {
                        result.error("PRINT_FAILED", error.message ?: "Could not print receipt.", null)
                    }
                }
            }.start()
        } catch (error: IllegalArgumentException) {
            result.error("INVALID_PRINTER", "Invalid Bluetooth printer address.", null)
        } catch (error: SecurityException) {
            result.error("BLUETOOTH_PERMISSION_REQUIRED", "Bluetooth permission is required.", null)
        }
    }

    private fun bluetoothAdapter(): BluetoothAdapter? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val manager = activity.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
            manager.adapter
        } else {
            @Suppress("DEPRECATION")
            BluetoothAdapter.getDefaultAdapter()
        }
    }

    private fun ensureBluetoothPermission(result: MethodChannel.Result): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return true
        }
        val permission = Manifest.permission.BLUETOOTH_CONNECT
        if (activity.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
            return true
        }
        activity.requestPermissions(arrayOf(permission), REQUEST_BLUETOOTH_CONNECT)
        result.error(
            "BLUETOOTH_PERMISSION_REQUIRED",
            "Bluetooth permission requested. Please approve it and try again.",
            null,
        )
        return false
    }

    private fun writeEscPosText(device: BluetoothDevice, text: String) {
        val socket = device.createRfcommSocketToServiceRecord(SPP_UUID)
        socket.use { activeSocket ->
            activeSocket.connect()
            val output = activeSocket.outputStream
            output.write(byteArrayOf(0x1B, 0x40)) // Initialize printer.
            output.write(text.toByteArray(ESC_POS_CHARSET))
            output.write(byteArrayOf(0x0A, 0x0A, 0x0A))
            output.write(byteArrayOf(0x1D, 0x56, 0x00)) // Partial cut where supported.
            output.flush()
        }
    }

    companion object {
        private const val CHANNEL = "com.wirespot.app/printer"
        private const val REQUEST_BLUETOOTH_CONNECT = 4204
        private val SPP_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
        private val ESC_POS_CHARSET: Charset = Charset.forName("CP437")
    }
}
