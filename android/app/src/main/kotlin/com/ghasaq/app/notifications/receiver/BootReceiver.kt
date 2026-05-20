package com.ghasaq.app.notifications.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.ghasaq.app.notifications.scheduler.RebuildCoordinator
import com.ghasaq.app.notifications.worker.RefreshScheduler

/**
 * Re-establishes the engine after the device reboots, the package updates,
 * or the user clears the app's running task. Without this every alarm
 * registered with AlarmManager is wiped on reboot — silent reliability bug.
 *
 * Listens to:
 *  - BOOT_COMPLETED        — normal post-unlock boot
 *  - LOCKED_BOOT_COMPLETED — fires before the user unlocks (encrypted boot)
 *  - MY_PACKAGE_REPLACED   — after self-update; alarms survive but the
 *                            foreground service does not
 *  - QUICKBOOT_POWERON     — vendor-specific quick boot intent (HTC/Samsung)
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action !in HANDLED_ACTIONS) return
        Log.i(TAG, "Rebuilding alarms after action=$action")
        RebuildCoordinator.rebuildAll(context)
        RefreshScheduler.ensurePeriodicWork(context)
    }

    companion object {
        private const val TAG = "GhasaqBootReceiver"
        private val HANDLED_ACTIONS = setOf(
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.LOCKED_BOOT_COMPLETED",
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
        )
    }
}
