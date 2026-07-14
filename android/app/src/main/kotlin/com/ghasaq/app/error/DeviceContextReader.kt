package com.ghasaq.app.error

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.view.InputDevice

/**
 * Collects TV device context for error reports served over the existing
 * `ghasaq/platform` channel: model / OS version / screen resolution / RAM /
 * memory pressure / remote input type.
 *
 * Best-effort by design: every probe degrades to a safe default and [read]
 * never throws across the channel — the Dart side guards as well, but a
 * crash inside crash-reporting must be impossible on both layers.
 */
class DeviceContextReader(private val context: Context) {

    fun read(): Map<String, Any> = try {
        val memory = memoryInfo()
        mapOf(
            "model" to (Build.MODEL ?: "unknown"),
            "manufacturer" to (Build.MANUFACTURER ?: "unknown"),
            "os_version" to (Build.VERSION.RELEASE ?: "unknown"),
            "sdk_int" to Build.VERSION.SDK_INT,
            "resolution" to screenResolution(),
            "ram_total_mb" to (memory?.totalMem ?: 0L) / BYTES_PER_MB,
            "ram_avail_mb" to (memory?.availMem ?: 0L) / BYTES_PER_MB,
            "low_memory" to (memory?.lowMemory ?: false),
            "input_type" to inputType(),
        )
    } catch (e: Exception) {
        mapOf("model" to (Build.MODEL ?: "unknown"))
    }

    private fun memoryInfo(): ActivityManager.MemoryInfo? = try {
        val manager =
            context.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
        ActivityManager.MemoryInfo().also { manager?.getMemoryInfo(it) }
    } catch (e: Exception) {
        null
    }

    private fun screenResolution(): String = try {
        val metrics = context.resources.displayMetrics
        "${metrics.widthPixels}x${metrics.heightPixels}"
    } catch (e: Exception) {
        "unknown"
    }

    /** Primary remote input; D-pad remotes rank above air-mouse and touch. */
    private fun inputType(): String = try {
        var hasDpad = false
        var hasMouse = false
        var hasTouch = false
        for (id in InputDevice.getDeviceIds()) {
            val device = InputDevice.getDevice(id) ?: continue
            val sources = device.sources
            if (sources and InputDevice.SOURCE_DPAD == InputDevice.SOURCE_DPAD) {
                hasDpad = true
            }
            if (sources and InputDevice.SOURCE_MOUSE == InputDevice.SOURCE_MOUSE) {
                hasMouse = true
            }
            if (sources and InputDevice.SOURCE_TOUCHSCREEN ==
                InputDevice.SOURCE_TOUCHSCREEN
            ) {
                hasTouch = true
            }
        }
        when {
            hasDpad -> "dpad"
            hasMouse -> "air_mouse"
            hasTouch -> "touch"
            else -> "unknown"
        }
    } catch (e: Exception) {
        "unknown"
    }

    private companion object {
        const val BYTES_PER_MB = 1024L * 1024L
    }
}
