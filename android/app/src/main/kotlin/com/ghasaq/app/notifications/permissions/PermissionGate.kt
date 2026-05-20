package com.ghasaq.app.notifications.permissions

import android.app.AlarmManager
import android.content.Context
import android.os.Build
import android.os.PowerManager
import androidx.core.app.NotificationManagerCompat

/**
 * Read-only checks that the [com.ghasaq.app.notifications.engine.PrayerAlarmEngine]
 * exposes to Flutter so the health screen can show actionable status. Asking
 * for any permission is the UI layer's job — this object only reports.
 */
object PermissionGate {

    fun snapshot(context: Context): Map<String, Boolean> {
        return mapOf(
            "postNotifications" to NotificationManagerCompat.from(context).areNotificationsEnabled(),
            "exactAlarm" to canScheduleExactAlarms(context),
            "batteryUnrestricted" to isIgnoringBatteryOptimizations(context),
        )
    }

    fun canScheduleExactAlarms(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        return am.canScheduleExactAlarms()
    }

    fun isIgnoringBatteryOptimizations(context: Context): Boolean {
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(context.packageName)
    }
}
