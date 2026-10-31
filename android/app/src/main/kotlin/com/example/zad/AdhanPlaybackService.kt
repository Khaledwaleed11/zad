
package com.example.zad

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import java.io.File

class AdhanPlaybackService : Service() {

    companion object {
        const val ACTION_PLAY = "com.example.zad.action.PLAY_ADHAN"
        const val ACTION_STOP = "com.example.zad.action.STOP_ADHAN"

        const val EXTRA_AUDIO_PATH = "audio_path"
        const val EXTRA_PRAYER_NAME = "prayer_name"

        private const val CHANNEL_ID = "zad_adhan_playback"
        private const val NOTIFICATION_ID = 7401
        private const val TAG = "AdhanPlaybackService"
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")
        createNotificationChannel()
    }

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int
    ): Int {
        Log.d(TAG, "onStartCommand: ${intent?.action}")

        when (intent?.action) {
            ACTION_STOP -> {
                stopPlayback()
                return START_NOT_STICKY
            }

            ACTION_PLAY -> {
                val audioPath = intent.getStringExtra(EXTRA_AUDIO_PATH)
                val prayerName =
                    intent.getStringExtra(EXTRA_PRAYER_NAME) ?: "الصلاة"

                if (audioPath.isNullOrBlank()) {
                    Log.e(TAG, "Audio path is missing")
                    stopSelf()
                    return START_NOT_STICKY
                }

                startPlayback(audioPath, prayerName)
            }

            else -> {
                Log.e(TAG, "Unknown service action")
                stopSelf()
                return START_NOT_STICKY
            }
        }

        return START_NOT_STICKY
    }

    private fun startPlayback(audioPath: String, prayerName: String) {
        stopPlayerOnly()

        try {
            val audioFile = File(audioPath)

            Log.d(TAG, "Starting playback: $audioPath")
            Log.d(TAG, "File exists: ${audioFile.exists()}")
            Log.d(TAG, "File readable: ${audioFile.canRead()}")
            Log.d(TAG, "File size: ${audioFile.length()}")

            if (!audioFile.exists() || !audioFile.canRead()) {
                throw IllegalStateException("Adhan audio file is unavailable")
            }

            startForegroundCompat(createNotification(prayerName))
            Log.d(TAG, "Foreground service started")

            acquireWakeLock()

            audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

            if (!requestAudioFocus()) {
                throw IllegalStateException("Could not obtain audio focus")
            }

            Log.d(TAG, "Audio focus granted")

            val player = MediaPlayer()

            player.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )

            player.setDataSource(audioPath)

            player.setOnCompletionListener {
                Log.d(TAG, "Adhan playback completed")
                stopPlayback()
            }

            player.setOnErrorListener { _, what, extra ->
                Log.e(TAG, "MediaPlayer error: what=$what, extra=$extra")
                stopPlayback()
                true
            }

            mediaPlayer = player

            player.setOnPreparedListener {
                try {
                    Log.d(TAG, "MediaPlayer prepared, starting audio")
                    it.start()
                    Log.d(TAG, "Adhan playback started")
                } catch (exception: Exception) {
                    Log.e(TAG, "Failed to start MediaPlayer", exception)
                    stopPlayback()
                }
            }

            player.prepareAsync()
            Log.d(TAG, "MediaPlayer preparation requested")

        } catch (exception: Exception) {
            Log.e(TAG, "Playback initialization failed", exception)
            stopPlayback()
        }
    }

    private fun requestAudioFocus(): Boolean {
        val manager = audioManager ?: return false

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val request = AudioFocusRequest.Builder(
                AudioManager.AUDIOFOCUS_GAIN
            )
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                .setOnAudioFocusChangeListener { focusChange ->
                    Log.d(TAG, "Audio focus changed: $focusChange")

                    if (focusChange == AudioManager.AUDIOFOCUS_LOSS) {
                        stopPlayback()
                    }
                }
                .build()

            audioFocusRequest = request

            manager.requestAudioFocus(request) ==
                    AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        } else {
            @Suppress("DEPRECATION")
            manager.requestAudioFocus(
                null,
                AudioManager.STREAM_ALARM,
                AudioManager.AUDIOFOCUS_GAIN
            ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        }
    }

    private fun abandonAudioFocus() {
        val manager = audioManager ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let {
                manager.abandonAudioFocusRequest(it)
            }
            audioFocusRequest = null
        } else {
            @Suppress("DEPRECATION")
            manager.abandonAudioFocus(null)
        }

        audioManager = null
    }

    private fun acquireWakeLock() {
        val powerManager =
            getSystemService(Context.POWER_SERVICE) as PowerManager

        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "ZAD:AdhanPlayback"
        ).apply {
            acquire(30 * 60 * 1000L)
        }

        Log.d(TAG, "Wake lock acquired")
    }

    private fun releaseWakeLock() {
        wakeLock?.let {
            if (it.isHeld) {
                it.release()
                Log.d(TAG, "Wake lock released")
            }
        }
        wakeLock = null
    }

    private fun createNotification(prayerName: String): Notification {
        val stopIntent = Intent(this, AdhanPlaybackService::class.java).apply {
            action = ACTION_STOP
        }

        val stopPendingIntent = PendingIntent.getService(
            this,
            7402,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        return builder
            .setContentTitle("الأذان")
            .setContentText("حان وقت صلاة $prayerName")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setCategory(Notification.CATEGORY_ALARM)
            .setPriority(Notification.PRIORITY_HIGH)
            .setOngoing(true)
            .addAction(
                android.R.drawable.ic_media_pause,
                "إيقاف الأذان",
                stopPendingIntent
            )
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "تشغيل الأذان",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "إشعار أثناء تشغيل الأذان"
                setSound(null, null)
                enableVibration(false)
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun startForegroundCompat(notification: Notification) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun stopPlayerOnly() {
        mediaPlayer?.let { player ->
            try {
                player.setOnPreparedListener(null)
                player.setOnCompletionListener(null)
                player.setOnErrorListener(null)

                if (player.isPlaying) {
                    player.stop()
                }

                player.reset()
                player.release()
            } catch (exception: Exception) {
                Log.w(TAG, "Error while releasing MediaPlayer", exception)
            }
        }

        mediaPlayer = null
    }

    private fun stopPlayback() {
        Log.d(TAG, "Stopping Adhan playback")

        stopPlayerOnly()
        abandonAudioFocus()
        releaseWakeLock()

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        Log.d(TAG, "Service destroyed")

        stopPlayerOnly()
        abandonAudioFocus()
        releaseWakeLock()

        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
