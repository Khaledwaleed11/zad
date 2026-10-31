
package com.example.zad

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import java.io.File

class AdhanAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        Log.d(TAG, "Alarm receiver triggered")

        if (intent?.action != ACTION_PLAY_ADHAN) {
            Log.w(TAG, "Unexpected alarm action: ${intent?.action}")
            return
        }

        val audioPath = intent.getStringExtra(EXTRA_AUDIO_PATH)
        val prayerName = intent.getStringExtra(EXTRA_PRAYER_NAME) ?: "الصلاة"

        if (audioPath.isNullOrBlank()) {
            Log.e(TAG, "Adhan audio path is missing")
            return
        }

        val audioFile = File(audioPath)

        Log.d(TAG, "Audio path: $audioPath")
        Log.d(TAG, "File exists: ${audioFile.exists()}")
        Log.d(TAG, "File readable: ${audioFile.canRead()}")
        Log.d(TAG, "File size: ${audioFile.length()}")

        if (!audioFile.exists() || !audioFile.canRead()) {
            Log.e(TAG, "Adhan audio file is unavailable")
            return
        }

        val serviceIntent = Intent(
            context,
            AdhanPlaybackService::class.java
        ).apply {
            action = AdhanPlaybackService.ACTION_PLAY
            putExtra(AdhanPlaybackService.EXTRA_AUDIO_PATH, audioPath)
            putExtra(AdhanPlaybackService.EXTRA_PRAYER_NAME, prayerName)
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }

            Log.d(TAG, "Playback service start requested")
        } catch (exception: Exception) {
            Log.e(TAG, "Failed to start Adhan playback service", exception)
        }
    }

    companion object {
        const val ACTION_PLAY_ADHAN = "com.example.zad.action.ALARM_ADHAN"
        const val EXTRA_AUDIO_PATH = "audio_path"
        const val EXTRA_PRAYER_NAME = "prayer_name"

        private const val TAG = "AdhanAlarmReceiver"
    }
}
