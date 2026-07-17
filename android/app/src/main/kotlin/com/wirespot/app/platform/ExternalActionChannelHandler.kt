package com.wirespot.app.platform

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ExternalActionChannelHandler(
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
            "open" -> open(call, result)
            else -> result.notImplemented()
        }
    }

    private fun open(call: MethodCall, result: MethodChannel.Result) {
        val action = call.argument<String>("action").orEmpty()
        val value = call.argument<String>("value").orEmpty().trim()
        if (value.isEmpty()) {
            result.success(false)
            return
        }

        val uri = when (action) {
            "email" -> Uri.parse("mailto:$value")
            "phone" -> Uri.parse("tel:$value")
            "website" -> Uri.parse(if (value.startsWith("http")) value else "https://$value")
            else -> null
        }
        if (uri == null) {
            result.success(false)
            return
        }

        val intent = when (action) {
            "phone" -> Intent(Intent.ACTION_DIAL, uri)
            "email" -> Intent(Intent.ACTION_SENDTO, uri)
            else -> Intent(Intent.ACTION_VIEW, uri)
        }

        try {
            activity.startActivity(intent)
            result.success(true)
        } catch (_: Exception) {
            result.success(false)
        }
    }

    companion object {
        private const val CHANNEL = "com.wirespot.app/external_actions"
    }
}
