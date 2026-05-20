package com.ghasaq.app.widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Re-arms the per-minute widget alarm after the device boots. Without this,
 * the AlarmManager queue is wiped on reboot and the widget freezes until the
 * user opens the app.
 */
class WidgetBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        when (intent?.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                WidgetAlarmScheduler.scheduleNextTick(context)
            }
        }
    }
}
