package com.ghasaq.app.notifications.builder

/**
 * Shared identifiers for notification channels. Kept stable across the
 * Flutter→Native migration so users keep their per-channel preferences
 * (sound override, DND bypass, importance) — Android binds those settings
 * to the channel id permanently.
 *
 * Mirrors the legacy IDs originally defined in
 * lib/features/notifications/data/notification_channels.dart.
 */
object NotificationChannelIds {
    const val ADHAN_PREFIX = "prayer_times_v5_"
    const val ADHAN_CUSTOM_PREFIX = "prayer_times_v5_custom_"
    const val PRE_ADHAN = "prayer_reminder_v1"
    const val IQAMA = "prayer_iqama_v1"
    const val PRE_IQAMA = "prayer_pre_iqama_v1"
    const val ADHKAR = "adhkar_reminder_v1"

    /** Built-in adhan asset → raw resource name (matches pubspec asset list). */
    val builtInAdhans: List<Pair<String, String>> = listOf(
        "default" to "adhan",
        "adhan2" to "adhan2",
    )

    fun adhanChannelId(rawName: String): String = "$ADHAN_PREFIX$rawName"

    fun customAdhanChannelId(fileName: String): String {
        val dot = fileName.lastIndexOf('.')
        val stem = if (dot > 0) fileName.substring(0, dot) else fileName
        return "$ADHAN_CUSTOM_PREFIX$stem"
    }
}
