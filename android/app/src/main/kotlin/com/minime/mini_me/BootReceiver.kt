package com.minime.mini_me

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/** Alarms are cleared by reboot, app update, and clock/timezone changes; re-register them. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        try {
            ReminderScheduler.rescheduleAll(context)
        } catch (e: Exception) {
            Log.e("BootReceiver", "Failed to reschedule", e)
        }
    }
}
