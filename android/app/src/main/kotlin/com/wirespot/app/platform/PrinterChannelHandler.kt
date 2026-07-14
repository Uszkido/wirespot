package com.wirespot.app.platform

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.io.OutputStream
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
        val logoAsset = call.argument<String>("logoAsset").orEmpty()
        val logoFile = call.argument<String>("logoFile").orEmpty()
        val paperWidth = call.argument<String>("paperWidth").orEmpty()
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
                    writeEscPosText(device, text, logoAsset, logoFile, paperWidth)
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

    private fun writeEscPosText(
        device: BluetoothDevice,
        text: String,
        logoAsset: String,
        logoFile: String,
        paperWidth: String,
    ) {
        val socket = device.createRfcommSocketToServiceRecord(SPP_UUID)
        socket.use { activeSocket ->
            activeSocket.connect()
            val output = activeSocket.outputStream
            output.write(byteArrayOf(0x1B, 0x40)) // Initialize printer.
            writeLogo(output, logoAsset, logoFile, paperWidth)
            output.write(text.toByteArray(ESC_POS_CHARSET))
            output.write(byteArrayOf(0x0A, 0x0A, 0x0A))
            output.write(byteArrayOf(0x1D, 0x56, 0x00)) // Partial cut where supported.
            output.flush()
        }
    }

    private fun writeLogo(
        output: OutputStream,
        logoAsset: String,
        logoFile: String,
        paperWidth: String,
    ) {
        if (logoAsset.isBlank() && logoFile.isBlank()) {
            return
        }
        try {
            val bitmap = if (logoFile.isNotBlank() && File(logoFile).exists()) {
                BitmapFactory.decodeFile(logoFile)
            } else {
                val assetPath = "flutter_assets/$logoAsset"
                activity.assets.open(assetPath).use { stream ->
                    BitmapFactory.decodeStream(stream)
                }
            } ?: return
            val maxWidth = if (paperWidth == "mm80") 384 else 256
            val scaled = scaleBitmap(bitmap, maxWidth)
            output.write(byteArrayOf(0x1B, 0x61, 0x01)) // Center.
            output.write(rasterCommand(scaled, printLightPixels = true))
            output.write(byteArrayOf(0x0A, 0x1B, 0x61, 0x00)) // Line feed, left.
        } catch (_: IOException) {
            // Logo printing is best-effort; the text receipt should still print.
        } catch (_: IllegalArgumentException) {
            // Some printers reject large raster blocks. Continue with text.
        }
    }

    private fun scaleBitmap(bitmap: Bitmap, maxWidth: Int): Bitmap {
        if (bitmap.width <= maxWidth) {
            return bitmap
        }
        val ratio = maxWidth.toFloat() / bitmap.width.toFloat()
        val targetHeight = (bitmap.height * ratio).toInt().coerceAtLeast(1)
        return Bitmap.createScaledBitmap(bitmap, maxWidth, targetHeight, true)
    }

    private fun rasterCommand(bitmap: Bitmap, printLightPixels: Boolean): ByteArray {
        val widthBytes = (bitmap.width + 7) / 8
        val height = bitmap.height
        val data = ByteArray(widthBytes * height)
        for (y in 0 until height) {
            for (x in 0 until bitmap.width) {
                val pixel = bitmap.getPixel(x, y)
                val red = pixel shr 16 and 0xFF
                val green = pixel shr 8 and 0xFF
                val blue = pixel and 0xFF
                val luminance = (red * 299 + green * 587 + blue * 114) / 1000
                val shouldPrint = if (printLightPixels) {
                    luminance > 150
                } else {
                    luminance < 128
                }
                if (shouldPrint) {
                    val index = y * widthBytes + x / 8
                    data[index] = (data[index].toInt() or (0x80 shr (x % 8))).toByte()
                }
            }
        }
        val xL = widthBytes and 0xFF
        val xH = widthBytes shr 8 and 0xFF
        val yL = height and 0xFF
        val yH = height shr 8 and 0xFF
        return byteArrayOf(
            0x1D,
            0x76,
            0x30,
            0x00,
            xL.toByte(),
            xH.toByte(),
            yL.toByte(),
            yH.toByte(),
        ) + data
    }

    companion object {
        private const val CHANNEL = "com.wirespot.app/printer"
        private const val REQUEST_BLUETOOTH_CONNECT = 4204
        private val SPP_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
        private val ESC_POS_CHARSET: Charset = Charset.forName("CP437")
    }
}
