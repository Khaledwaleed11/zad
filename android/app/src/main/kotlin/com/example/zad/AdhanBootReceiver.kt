
package com.example.zad

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class AdhanBootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        when (intent?.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> {
                try {
                    AdhanAlarmScheduler.rescheduleSavedAlarms(context)
                    Log.d(TAG, "Adhan alarms rescheduled successfully")
                } catch (exception: Exception) {
                    Log.e(TAG, "Failed to reschedule Adhan alarms", exception)
                }
            }
        }
    }

    companion object {
        private const val TAG = "AdhanBootReceiver"
    }
}
