
package com.example.zad

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

data class AdhanAlarm(
    val id: Int,
    val triggerAtMillis: Long,
    val audioPath: String,
    val prayerName: String
)

object AdhanAlarmScheduler {

    private const val PREFS_NAME = "zad_adhan_alarms"
    private const val ALARMS_KEY = "scheduled_alarms"

    // Keep only 35 Adhan alarms active in Android at a time.
    private const val MAX_ACTIVE_ALARMS = 35

    private const val TAG = "AdhanAlarmScheduler"

    /**
     * Replaces the complete upcoming Adhan schedule.
     * All future alarms are stored, but only the first 35 are activated.
     */
    fun scheduleWindow(
        context: Context,
        alarms: List<AdhanAlarm>
    ) {
        cancelAll(context)

        val futureAlarms = alarms
            .filter {
                it.triggerAtMillis > System.currentTimeMillis() &&
                        it.audioPath.isNotBlank()
            }
            .distinctBy { it.id }
            .sortedBy { it.triggerAtMillis }

        val storedAlarms = JSONArray()

        futureAlarms.forEach { alarm ->
            storedAlarms.put(
                JSONObject().apply {
                    put("id", alarm.id)
                    put("time", alarm.triggerAtMillis)
                    put("audioPath", alarm.audioPath)
                    put("prayerName", alarm.prayerName)
                    put("active", false)
                }
            )
        }

        saveAlarms(context, storedAlarms)

        scheduleNextBatch(context)

        Log.d(
            TAG,
            "Stored ${futureAlarms.size} alarms. Active limit: $MAX_ACTIVE_ALARMS"
        )
    }

    /**
     * Called when an Adhan alarm is triggered.
     * Removes the fired alarm and activates the next pending alarm.
     */
    fun onAlarmTriggered(context: Context, alarmId: Int) {
        val alarms = readSavedAlarms(context)
        val updated = JSONArray()

        for (index in 0 until alarms.length()) {
            val alarm = alarms.optJSONObject(index) ?: continue

            if (alarm.optInt("id") != alarmId) {
                updated.put(alarm)
            }
        }

        saveAlarms(context, updated)

        scheduleNextBatch(context)

        Log.d(TAG, "Processed alarm $alarmId")
    }

    /**
     * Restores the active alarm window after device restart.
     */
    fun rescheduleSavedAlarms(context: Context) {
        val alarms = readSavedAlarms(context)
        val now = System.currentTimeMillis()
        val updated = JSONArray()

        for (index in 0 until alarms.length()) {
            val alarm = alarms.optJSONObject(index) ?: continue

            if (alarm.optLong("time", 0L) > now) {
                alarm.put("active", false)
                updated.put(alarm)
            }
        }

        saveAlarms(context, updated)

        scheduleNextBatch(context)

        Log.d(TAG, "Saved Adhan alarms restored")
    }

    /**
     * Cancels every currently scheduled Adhan alarm and clears the queue.
     */
    fun cancelAll(context: Context) {
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
                alarmId = alarmId
            )

            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
        }

        context.getSharedPreferences(
            PREFS_NAME,
            Context.MODE_PRIVATE
        ).edit()
            .remove(ALARMS_KEY)
            .apply()
    }

    /**
     * Activates the earliest pending alarms until the active limit is reached.
     */
    private fun scheduleNextBatch(context: Context) {
        val alarms = readSavedAlarms(context)
        val now = System.currentTimeMillis()

        val activeCount = countActiveAlarms(alarms)

        var availableSlots = MAX_ACTIVE_ALARMS - activeCount

        if (availableSlots <= 0) return

        val alarmManager = context.getSystemService(
            Context.ALARM_SERVICE
        ) as AlarmManager

        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            !alarmManager.canScheduleExactAlarms()
        ) {
            Log.w(TAG, "Exact alarm permission is not granted")
            return
        }

        val updated = JSONArray()

        val pendingAlarms = mutableListOf<JSONObject>()

        for (index in 0 until alarms.length()) {
            val alarm = alarms.optJSONObject(index) ?: continue

            if (alarm.optLong("time", 0L) <= now) {
                continue
            }

            updated.put(alarm)

            if (!alarm.optBoolean("active", false)) {
                pendingAlarms.add(alarm)
            }
        }

        pendingAlarms.sortBy { it.optLong("time", 0L) }

        for (alarm in pendingAlarms) {
            if (availableSlots <= 0) break

            val alarmId = alarm.optInt("id", -1)
            val triggerAtMillis = alarm.optLong("time", 0L)
            val audioPath = alarm.optString("audioPath")
            val prayerName = alarm.optString("prayerName", "الصلاة")

            if (
                alarmId < 0 ||
                triggerAtMillis <= now ||
                audioPath.isBlank()
            ) {
                continue
            }

            try {
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

                alarm.put("active", true)
                availableSlots--

                Log.d(TAG, "Activated Adhan alarm: $alarmId")
            } catch (exception: Exception) {
                Log.e(
                    TAG,
                    "Failed to activate Adhan alarm $alarmId",
                    exception
                )
            }
        }

        saveAlarms(context, updated)

        Log.d(
            TAG,
            "Active alarms: ${countActiveAlarms(updated)}"
        )
    }

    private fun countActiveAlarms(alarms: JSONArray): Int {
        var count = 0

        for (index in 0 until alarms.length()) {
            val alarm = alarms.optJSONObject(index) ?: continue

            if (alarm.optBoolean("active", false)) {
                count++
            }
        }

        return count
    }

    private const val EXTRA_ALARM_ID = "adhan_alarm_id"

    private fun createPendingIntent(
        context: Context,
        alarmId: Int,
        audioPath: String = "",
        prayerName: String = ""
    ): PendingIntent {
        val intent = Intent(
            context,
            AdhanAlarmReceiver::class.java
        ).apply {
            action = AdhanAlarmReceiver.ACTION_PLAY_ADHAN
            putExtra(AdhanAlarmReceiver.EXTRA_AUDIO_PATH, audioPath)
            putExtra(AdhanAlarmReceiver.EXTRA_PRAYER_NAME, prayerName)
            putExtra(AdhanAlarmReceiver.EXTRA_ALARM_ID, alarmId)
        }

        return PendingIntent.getBroadcast(
            context,
            alarmId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun saveAlarms(
        context: Context,
        alarms: JSONArray
    ) {
        context.getSharedPreferences(
            PREFS_NAME,
            Context.MODE_PRIVATE
        ).edit()
            .putString(ALARMS_KEY, alarms.toString())
            .apply()
    }

    private fun readSavedAlarms(context: Context): JSONArray {
        val json = context.getSharedPreferences(
            PREFS_NAME,
            Context.MODE_PRIVATE
        ).getString(ALARMS_KEY, null)

        return try {
            if (json.isNullOrBlank()) {
                JSONArray()
            } else {
                JSONArray(json)
            }
        } catch (_: Exception) {
            JSONArray()
        }
    }
}
