package com.example.view_to_donate

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.vungle.ads.VunglePrivacySettings

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.view_to_donate/privacy"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setGDPRStatus" -> {
                    val status = call.argument<Boolean>("status") ?: false
                    val version = call.argument<String>("version") ?: "v1.0.0"
                    VunglePrivacySettings.setGDPRStatus(status, version)
                    result.success(null)
                }
                "setCCPAStatus" -> {
                    val status = call.argument<Boolean>("status") ?: false
                    VunglePrivacySettings.setCCPAStatus(status)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}