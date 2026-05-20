package com.ghasaq.app.notifications.models

import org.json.JSONObject

/**
 * One concrete notification that the [com.ghasaq.app.notifications.scheduler.AlarmScheduler]
 * will hand to AlarmManager. Persisted as JSON in NotificationStore so receivers
 * can rebuild it after process death without going back to Flutter.
 */
data class ScheduledNotification(
    val id: Int,
    val type: NotificationType,
    val triggerAtMillis: Long,
    val title: String,
    val body: String,
    val channelId: String,
    val payload: String?,
    val soundUri: String?,
    val prayerKey: String?,
    val dayIndex: Int,
) {
    fun toJson(): JSONObject = JSONObject().apply {
        put("id", id)
        put("type", type.key)
        put("triggerAtMillis", triggerAtMillis)
        put("title", title)
        put("body", body)
        put("channelId", channelId)
        put("payload", payload ?: JSONObject.NULL)
        put("soundUri", soundUri ?: JSONObject.NULL)
        put("prayerKey", prayerKey ?: JSONObject.NULL)
        put("dayIndex", dayIndex)
    }

    companion object {
        fun fromJson(json: JSONObject): ScheduledNotification = ScheduledNotification(
            id = json.getInt("id"),
            type = NotificationType.fromKey(json.getString("type"))
                ?: error("Unknown notification type: ${json.getString("type")}"),
            triggerAtMillis = json.getLong("triggerAtMillis"),
            title = json.getString("title"),
            body = json.getString("body"),
            channelId = json.getString("channelId"),
            payload = json.optString("payload").takeIf { it.isNotEmpty() && it != "null" },
            soundUri = json.optString("soundUri").takeIf { it.isNotEmpty() && it != "null" },
            prayerKey = json.optString("prayerKey").takeIf { it.isNotEmpty() && it != "null" },
            dayIndex = json.getInt("dayIndex"),
        )
    }
}
