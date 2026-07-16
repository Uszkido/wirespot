package com.wirespot.app.platform

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PlayStoreChannelHandler(
    private val context: Context,
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
            "openSubscriptions" -> openSubscriptions(result)
            else -> result.notImplemented()
        }
    }

    private fun openSubscriptions(result: MethodChannel.Result) {
        val packageName = context.packageName
        val subscriptionUri = Uri.parse(
            "https://play.google.com/store/account/subscriptions?package=$packageName",
        )
        val appUri = Uri.parse("market://details?id=$packageName")
        val browserUri = Uri.parse("https://play.google.com/store/apps/details?id=$packageName")

        try {
            context.startActivity(
                Intent(Intent.ACTION_VIEW, subscriptionUri).apply {
                    setPackage("com.android.vending")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                },
            )
            result.success(true)
        } catch (_: ActivityNotFoundException) {
            try {
                context.startActivity(
                    Intent(Intent.ACTION_VIEW, appUri).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    },
                )
                result.success(true)
            } catch (_: ActivityNotFoundException) {
                try {
                    context.startActivity(
                        Intent(Intent.ACTION_VIEW, browserUri).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        },
                    )
                    result.success(true)
                } catch (_: ActivityNotFoundException) {
                    result.error(
                        "play_store_unavailable",
                        "Google Play subscriptions could not be opened on this device.",
                        null,
                    )
                }
            }
        }
    }

    companion object {
        private const val CHANNEL = "com.wirespot.app/play_store"
    }
}
