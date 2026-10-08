package com.minime.mini_me

import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

/** Native copy of a reminder. repeat: "daily" | "weekly" | "interval". days: ISO 1=Mon..7=Sun. */
data class Reminder(
    val id: String,
    val title: String,
    val message: String,
    val hour: Int,
    val minute: Int,
    val repeat: String,
    val days: Set<Int>,
    val intervalHours: Int,
    val enabled: Boolean,
) {
    companion object {
        fun listFromJson(json: String?): List<Reminder> {
            if (json.isNullOrBlank()) return emptyList()
            return try {
                val arr = JSONArray(json)
                (0 until arr.length()).mapNotNull { i ->
                    runCatching { fromJson(arr.getJSONObject(i)) }.getOrNull()
                }
            } catch (e: JSONException) {
                emptyList()
            }
        }

        private fun fromJson(o: JSONObject): Reminder {
            val daysArr = o.optJSONArray("days")
            val days = if (daysArr == null) emptySet<Int>()
            else (0 until daysArr.length()).map { daysArr.getInt(it) }.toSet()
            return Reminder(
                id = o.getString("id"),
                title = o.optString("title"),
                message = o.optString("message", "Hi! I'm MiniMe 👋"),
                hour = o.getInt("hour").coerceIn(0, 23),
                minute = o.getInt("minute").coerceIn(0, 59),
                repeat = o.optString("repeat", "daily"),
                days = days,
                intervalHours = o.optInt("intervalHours", 2),
                enabled = o.optBoolean("enabled", true),
            )
        }
    }
}
