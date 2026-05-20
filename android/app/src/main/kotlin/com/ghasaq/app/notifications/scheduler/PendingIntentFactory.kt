package com.ghasaq.app.notifications.scheduler

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.ghasaq.app.notifications.receiver.AlarmReceiver

/**
 * Builds the PendingIntents that AlarmManager fires. Uses FLAG_IMMUTABLE
 * (mandatory on API 31+) to prevent third-party apps from rewriting our
 * intent extras after the fact — security hardening for any broadcast
 * that ships across the system.
 */
object PendingIntentFactory {

    const val EXTRA_ID = "ghasaq.notif.id"

    fun forAlarm(context: Context, id: Int): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            // Unique action keeps PendingIntent.equals() from collapsing
            // distinct alarms onto the same registration.
            action = "$ACTION_FIRE.$id"
            putExtra(EXTRA_ID, id)
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(context, id, intent, flags)
    }

    /** Used by [AlarmScheduler.cancel] to retrieve the same PendingIntent. */
    fun cancellationIntent(context: Context, id: Int): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = "$ACTION_FIRE.$id"
        }
        val flags = PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(context, id, intent, flags)
            ?: PendingIntent.getBroadcast(
                context, id, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
    }

    private const val ACTION_FIRE = "com.ghasaq.app.notifications.FIRE"
}
