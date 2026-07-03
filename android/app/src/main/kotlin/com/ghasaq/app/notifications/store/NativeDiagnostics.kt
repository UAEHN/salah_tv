package com.ghasaq.app.notifications.store

import android.content.Context
import android.util.Base64
import java.security.SecureRandom
import org.json.JSONArray
import org.json.JSONObject

class NativeDiagnostics(context: Context) {
    private val appContext = context.applicationContext
    private val prefs = context.applicationContext
        .getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun record(level: String, name: String, fields: JSONObject = JSONObject()) {
        enrich(fields)
        val entries = readAll().toMutableList()
        entries.add(0, JSONObject().apply {
            put("at", System.currentTimeMillis())
            put("level", level)
            put("name", name)
            put("fields", fields)
        })
        while (entries.size > MAX_ENTRIES) entries.removeAt(entries.size - 1)
        val arr = JSONArray()
        entries.forEach { arr.put(it) }
        prefs.edit().putString(KEY_EVENTS, arr.toString()).apply()
    }

    fun readAll(): List<JSONObject> {
        val raw = prefs.getString(KEY_EVENTS, null) ?: return emptyList()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).map { arr.getJSONObject(it) }
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun toJsonArray(): JSONArray = JSONArray().also { arr ->
        readAll().forEach { arr.put(it) }
    }

    private fun enrich(fields: JSONObject) {
        fields.put("sessionId", sessionId)
        installationId()?.let { fields.put("installationId", it) }
    }

    private fun installationId(): String? {
        val flutterPrefs = appContext.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE,
        )
        return flutterPrefs.getString("flutter.push.installId", null)
            ?.takeIf { it.isNotEmpty() }
    }

    companion object {
        private const val PREFS = "ghasaq_native_diagnostics_v1"
        private const val KEY_EVENTS = "events_json"
        private const val MAX_ENTRIES = 200
        private val sessionId: String by lazy {
            val bytes = ByteArray(12)
            SecureRandom().nextBytes(bytes)
            Base64.encodeToString(
                bytes,
                Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING,
            )
        }
    }
}
