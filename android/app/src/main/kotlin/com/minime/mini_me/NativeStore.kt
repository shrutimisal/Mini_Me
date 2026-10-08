package com.minime.mini_me

import android.content.Context

/**
 * Native-side copy of reminders/settings. Alarms fire when Flutter is not running,
 * so the receivers must be able to read everything without the Dart side.
 */
object NativeStore {
    private const val PREFS = "minime_native"
    private const val KEY_REMINDERS = "reminders"
    private const val KEY_SETTINGS = "settings"
    private const val KEY_SCHEDULED = "scheduled_ids"

    private fun prefs(ctx: Context) = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun saveReminders(ctx: Context, json: String) =
        prefs(ctx).edit().putString(KEY_REMINDERS, json).apply()

    fun reminders(ctx: Context): List<Reminder> =
        Reminder.listFromJson(prefs(ctx).getString(KEY_REMINDERS, null))

    fun saveSettings(ctx: Context, json: String) =
        prefs(ctx).edit().putString(KEY_SETTINGS, json).apply()

    fun settings(ctx: Context): OverlaySettings =
        OverlaySettings.fromJson(prefs(ctx).getString(KEY_SETTINGS, null))

    fun scheduledIds(ctx: Context): Set<String> =
        prefs(ctx).getStringSet(KEY_SCHEDULED, emptySet()) ?: emptySet()

    fun saveScheduledIds(ctx: Context, ids: Set<String>) =
        prefs(ctx).edit().putStringSet(KEY_SCHEDULED, ids).apply()
}
