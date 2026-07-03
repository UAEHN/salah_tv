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
    // v2 carries a real sound (bundled `iqama.mp3` by default, or a custom
    // imported file). A channel's sound is immutable after creation, so the
    // silent v1 above cannot be upgraded in place — v2 is a fresh channel.
    const val IQAMA_V2 = "prayer_iqama_v2"
    const val IQAMA_CUSTOM_PREFIX = "prayer_iqama_v2_custom_"
    const val IQAMA_RAW = "iqama"
    const val PRE_IQAMA = "prayer_pre_iqama_v1"
    const val ADHKAR = "adhkar_reminder_v1"
    const val AL_KAHF = "al_kahf_reminder_v1"
    // Server-pushed broadcasts (daily verse, announcements, milestones).
    // Kept separate so users can mute push without affecting prayer alarms.
    const val GENERAL_PUSH = "general_push_v1"

    /** Built-in adhan asset → raw resource name (matches pubspec asset list). */
    val builtInAdhans: List<Pair<String, String>> = listOf(
        "default" to "adhan",
        "adhan2" to "adhan2",
    )

    fun adhanChannelId(rawName: String): String = "$ADHAN_PREFIX$rawName"

    fun customAdhanChannelId(fileName: String): String =
        "$ADHAN_CUSTOM_PREFIX${stem(fileName)}"

    fun customIqamaChannelId(fileName: String): String =
        "$IQAMA_CUSTOM_PREFIX${stem(fileName)}"

    private fun stem(fileName: String): String {
        val dot = fileName.lastIndexOf('.')
        return if (dot > 0) fileName.substring(0, dot) else fileName
    }
}
