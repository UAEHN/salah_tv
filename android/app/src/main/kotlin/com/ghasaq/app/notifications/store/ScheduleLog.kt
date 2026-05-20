package com.ghasaq.app.notifications.store

import android.content.Context
import android.content.SharedPreferences
import com.ghasaq.app.notifications.models.NotificationType
import org.json.JSONArray
import org.json.JSONObject

/**
 * Circular log of the last [MAX_ENTRIES] alarm firings. Powers the
 * "Notification Health" diagnostic screen so users can verify reliability
 * (especially on aggressive OEMs where alarms silently drop).
 *
 * Stores no PII — only type, prayer key, scheduled-vs-fired timestamps,
 * and a success flag.
 */
class ScheduleLog(context: Context) {

    private val prefs: SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun record(
        id: Int,
        type: NotificationType,
        prayerKey: String?,
        scheduledFor: Long,
        success: Boolean,
        error: String? = null,
    ) {
        val entries = readAll().toMutableList()
        entries.add(0, Entry(
            id = id,
            type = type,
            prayerKey = prayerKey,
            scheduledFor = scheduledFor,
            firedAt = System.currentTimeMillis(),
            success = success,
            error = error,
        ))
        while (entries.size > MAX_ENTRIES) entries.removeAt(entries.size - 1)
        val arr = JSONArray()
        entries.forEach { arr.put(it.toJson()) }
        prefs.edit().putString(KEY_LOG, arr.toString()).apply()
    }

    fun readAll(): List<Entry> {
        val raw = prefs.getString(KEY_LOG, null) ?: return emptyList()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).map { Entry.fromJson(arr.getJSONObject(it)) }
        } catch (e: Exception) {
            emptyList()
        }
    }

    fun clear() = prefs.edit().remove(KEY_LOG).apply()

    data class Entry(
        val id: Int,
        val type: NotificationType,
        val prayerKey: String?,
        val scheduledFor: Long,
        val firedAt: Long,
        val success: Boolean,
        val error: String?,
    ) {
        fun toJson(): JSONObject = JSONObject().apply {
            put("id", id)
            put("type", type.key)
            put("prayerKey", prayerKey ?: JSONObject.NULL)
            put("scheduledFor", scheduledFor)
            put("firedAt", firedAt)
            put("success", success)
            put("error", error ?: JSONObject.NULL)
        }
        companion object {
            fun fromJson(j: JSONObject) = Entry(
                id = j.getInt("id"),
                type = NotificationType.fromKey(j.getString("type"))!!,
                prayerKey = j.optString("prayerKey").takeIf { it.isNotEmpty() && it != "null" },
                scheduledFor = j.getLong("scheduledFor"),
                firedAt = j.getLong("firedAt"),
                success = j.getBoolean("success"),
                error = j.optString("error").takeIf { it.isNotEmpty() && it != "null" },
            )
        }
    }

    companion object {
        private const val PREFS = "ghasaq_schedule_log_v1"
        private const val KEY_LOG = "entries_json"
        private const val MAX_ENTRIES = 100
    }
}
