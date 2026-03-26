package com.ghasaq.app

import android.app.UiModeManager
import android.content.Context
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestHighRefreshRate()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ghasaq/platform",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isTV" -> result.success(isTvDevice())
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Requests the highest refresh rate the display supports (90/120/144Hz).
     * Android keeps the display at 60Hz by default unless the app explicitly
     * requests a higher mode via preferredDisplayModeId.
     */
    private fun requestHighRefreshRate() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return

        val display = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            display
        } else {
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay
        }

        val bestMode = display?.supportedModes
            ?.maxByOrNull { it.refreshRate }
            ?: return

        window.attributes = window.attributes.apply {
            preferredDisplayModeId = bestMode.modeId
        }
    }

    private fun isTvDevice(): Boolean {
        val uiModeManager = getSystemService(Context.UI_MODE_SERVICE) as? UiModeManager
        val currentMode = resources.configuration.uiMode and Configuration.UI_MODE_TYPE_MASK
        return currentMode == Configuration.UI_MODE_TYPE_TELEVISION ||
            uiModeManager?.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION
    }
}
