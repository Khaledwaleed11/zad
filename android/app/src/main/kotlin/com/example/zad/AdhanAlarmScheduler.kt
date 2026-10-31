
package com.example.zad

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject

object AdhanAlarmScheduler {

    private const val PREFS_NAME = "zad_adhan_alarms"
    private const val ALARMS_KEY = "scheduled_alarms"

    fun schedule(
        context: Context,
        alarmId: Int,
        triggerAtMillis: Long,
        audioPath: String,
        prayerName: String
    ) {
        require(audioPath.isNotBlank()) {
            "Adhan audio path is missing"
        }

        require(triggerAtMillis > System.currentTimeMillis()) {
            "Adhan alarm time must be in the future"
        }

        val alarmManager = context.getSystemService(
            Context.ALARM_SERVICE
        ) as AlarmManager

        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            !alarmManager.canScheduleExactAlarms()
        ) {
            throw SecurityException(
                "Exact alarm permission is not granted"
            )
        }

        val pendingIntent = createPendingIntent(
            context = context,
            alarmId = alarmId,
            audioPath = audioPath,
            prayerName = prayerName
        )

        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            triggerAtMillis,
            pendingIntent
        )

        saveAlarm(
            context = context,
            alarmId = alarmId,
            triggerAtMillis = triggerAtMillis,
            audioPath = audioPath,
            prayerName = prayerName
        )
    }

    fun cancel(context: Context, alarmId: Int) {
        val alarmManager = context.getSystemService(
            Context.ALARM_SERVICE
        ) as AlarmManager

        val pendingIntent = createPendingIntent(
            context = context,
            alarmId = alarmId,
            audioPath = "",
            prayerName = ""
        )

        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()

        removeSavedAlarm(context, alarmId)
    }

    fun cancelAll(context: Context) {
        val prefs = context.getSharedPreferences(
            PREFS_NAME,
            Context.MODE_PRIVATE
        )

        val alarms = readSavedAlarms(context)
        val alarmManager = context.getSystemService(
            Context.ALARM_SERVICE
        ) as AlarmManager

        for (index in 0 until alarms.length()) {
            val alarm = alarms.optJSONObject(index) ?: continue
            val alarmId = alarm.optInt("id", -1)

            if (alarmId < 0) continue

            val pendingIntent = createPendingIntent(
                context = context,
                alarmId = alarmId,
                audioPath = "",
                prayerName = ""
            )

            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
        }

        prefs.edit().remove(ALARMS_KEY).apply()
    }

    fun rescheduleSavedAlarms(context: Context) {
        val alarms = readSavedAlarms(context)

        for (index in 0 until alarms.length()) {
            val alarm = alarms.optJSONObject(index) ?: continue

            val alarmId = alarm.optInt("id", -1)
            val triggerAtMillis = alarm.optLong("time", 0L)
            val audioPath = alarm.optString("audioPath")
            val prayerName = alarm.optString("prayerName", "الصلاة")

            if (alarmId < 0 || triggerAtMillis <= System.currentTimeMillis()) {
                continue
            }

            if (audioPath.isBlank()) continue

            try {
                schedule(
                    context = context,
                    alarmId = alarmId,
                    triggerAtMillis = triggerAtMillis,
                    audioPath = audioPath,
                    prayerName = prayerName
                )
            } catch (_: Exception) {
                // Keep other alarms scheduled if one alarm fails.
            }
        }
    }

    private fun createPendingIntent(
        context: Context,
        alarmId: Int,
        audioPath: String,
        prayerName: String
    ): PendingIntent {
        val intent = Intent(
            context,
            AdhanAlarmReceiver::class.java
        ).apply {
            action = AdhanAlarmReceiver.ACTION_PLAY_ADHAN
            putExtra(AdhanAlarmReceiver.EXTRA_AUDIO_PATH, audioPath)
            putExtra(AdhanAlarmReceiver.EXTRA_PRAYER_NAME, prayerName)
        }

        return PendingIntent.getBroadcast(
            context,
            alarmId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun saveAlarm(
        context: Context,
        alarmId: Int,
        triggerAtMillis: Long,
        audioPath: String,
        prayerName: String
    ) {
        val alarms = readSavedAlarms(context)

        val updated = JSONArray()

        for (index in 0 until alarms.length()) {
            val alarm = alarms.optJSONObject(index) ?: continue

            if (alarm.optInt("id") != alarmId) {
                updated.put(alarm)
            }
        }

        updated.put(
            JSONObject().apply {
                put("id", alarmId)
                put("time", triggerAtMillis)
                put("audioPath", audioPath)
                put("prayerName", prayerName)
            }
        )

        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(ALARMS_KEY, updated.toString())
            .apply()
    }

    private fun removeSavedAlarm(context: Context, alarmId: Int) {
        val alarms = readSavedAlarms(context)
        val updated = JSONArray()

        for (index in 0 until alarms.length()) {
            val alarm = alarms.optJSONObject(index) ?: continue

            if (alarm.optInt("id") != alarmId) {
                updated.put(alarm)
            }
        }

        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(ALARMS_KEY, updated.toString())
            .apply()
    }

    private fun readSavedAlarms(context: Context): JSONArray {
        val json = context.getSharedPreferences(
            PREFS_NAME,
            Context.MODE_PRIVATE
        ).getString(ALARMS_KEY, null)

        return try {
            if (json.isNullOrBlank()) JSONArray() else JSONArray(json)
        } catch (_: Exception) {
            JSONArray()
        }
    }
}
