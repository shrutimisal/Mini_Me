package com.minime.mini_me

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/** Runs when a reminder alarm fires, even if the Flutter app is closed. */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getStringExtra(ReminderScheduler.EXTRA_ID) ?: return
        try {
            val reminder = NativeStore.reminders(context).firstOrNull { it.id == id } ?: return
            if (!reminder.enabled) return

            // Queue the next occurrence first; the margin avoids re-firing the same instant.
            ReminderScheduler.schedule(context, reminder, System.currentTimeMillis() + 30_000)

            if (NativeStore.settings(context).isQuietNow()) return
            // Allowed from the background because the app holds SYSTEM_ALERT_WINDOW.
            OverlayService.start(context, reminder.message, -1L)
        } catch (e: Exception) {
            Log.e("AlarmReceiver", "Failed handling alarm", e)
        }
    }
}
