package com.wirespot.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.wirespot.app.platform.PrinterChannelHandler
import com.wirespot.app.platform.ShareChannelHandler
import com.wirespot.app.vpn.WireGuardChannelHandler
import com.wirespot.app.vpn.WireGuardTunnelManager

class MainActivity : FlutterActivity() {
    private var wireGuardChannelHandler: WireGuardChannelHandler? = null
    private var printerChannelHandler: PrinterChannelHandler? = null
    private var shareChannelHandler: ShareChannelHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        wireGuardChannelHandler = WireGuardChannelHandler(
            activity = this,
            binaryMessenger = flutterEngine.dartExecutor.binaryMessenger,
        ).also { it.attach() }
        printerChannelHandler = PrinterChannelHandler(
            activity = this,
            binaryMessenger = flutterEngine.dartExecutor.binaryMessenger,
        ).also { it.attach() }
        shareChannelHandler = ShareChannelHandler(
            context = this,
            binaryMessenger = flutterEngine.dartExecutor.binaryMessenger,
        ).also { it.attach() }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        wireGuardChannelHandler?.detach()
        wireGuardChannelHandler = null
        printerChannelHandler?.detach()
        printerChannelHandler = null
        shareChannelHandler?.detach()
        shareChannelHandler = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == WireGuardTunnelManager.VPN_PERMISSION_REQUEST_CODE) {
            wireGuardChannelHandler?.onVpnPermissionResult(resultCode)
        }
    }
}
