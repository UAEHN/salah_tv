package com.ghasaq.app.error

import android.content.Context
import org.json.JSONObject
import java.io.File

/**
 * Captures JVM-level uncaught exceptions — native/plugin crashes that never
 * surface to Dart — by writing a small JSON marker to filesDir, then
 * delegating to the previously-installed handler so Firebase Crashlytics still
 * reports the same crash.
 *
 * The Dart side (`native_crash_bridge.dart`) consumes the marker on the next
 * boot and files it as an `error_event` with `kind='native_crash'`, carrying
 * the previous session's breadcrumb trail.
 *
 * Never throws out of [uncaughtException]: a fault inside the crash handler
 * must neither mask the original crash nor break the delegate chain.
 */
class NativeCrashMarkerHandler private constructor(
    context: Context,
    private val previous: Thread.UncaughtExceptionHandler?,
) : Thread.UncaughtExceptionHandler {

    private val markerFile = File(context.filesDir, MARKER_NAME)

    override fun uncaughtException(thread: Thread, throwable: Throwable) {
        try {
            markerFile.writeText(marker(thread, throwable).toString())
        } catch (_: Throwable) {
            // Writing the marker must never mask the real crash.
        } finally {
            previous?.uncaughtException(thread, throwable)
        }
    }

    private fun marker(thread: Thread, throwable: Throwable): JSONObject {
        val root = rootCause(throwable)
        return JSONObject().apply {
            put("error_type", root.javaClass.name)
            put("message", (root.message ?: root.javaClass.simpleName).take(MAX_MESSAGE))
            put("thread", thread.name)
            put("stack", stackText(root).take(MAX_STACK))
            put("at", System.currentTimeMillis())
        }
    }

    private fun rootCause(throwable: Throwable): Throwable {
        var cause: Throwable = throwable
        var depth = 0
        while (depth < MAX_CAUSE_DEPTH) {
            val next = cause.cause ?: break
            if (next === cause) break
            cause = next
            depth++
        }
        return cause
    }

    private fun stackText(throwable: Throwable): String {
        val sb = StringBuilder(throwable.toString()).append('\n')
        for (frame in throwable.stackTrace.take(MAX_FRAMES)) {
            sb.append("    at ").append(frame.toString()).append('\n')
        }
        return sb.toString()
    }

    companion object {
        private const val MARKER_NAME = "native_crash_marker.json"
        private const val MAX_MESSAGE = 2048
        private const val MAX_STACK = 12000
        private const val MAX_FRAMES = 60
        private const val MAX_CAUSE_DEPTH = 10

        /** Installs the chain-delegating handler. Idempotent + fail-soft. */
        fun install(context: Context) {
            try {
                val current = Thread.getDefaultUncaughtExceptionHandler()
                if (current is NativeCrashMarkerHandler) return
                Thread.setDefaultUncaughtExceptionHandler(
                    NativeCrashMarkerHandler(context.applicationContext, current),
                )
            } catch (_: Throwable) {
                // Never block startup on crash-handler installation.
            }
        }

        /** Reads + deletes the marker a prior-session crash left behind. */
        fun consume(context: Context): String? {
            return try {
                val file = File(context.filesDir, MARKER_NAME)
                if (!file.exists()) return null
                val text = file.readText()
                file.delete()
                text.ifBlank { null }
            } catch (_: Throwable) {
                null
            }
        }
    }
}
