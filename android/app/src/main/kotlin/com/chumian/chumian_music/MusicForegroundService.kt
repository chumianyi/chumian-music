package com.chumian.chumian_music

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.wifi.WifiManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import androidx.media.app.NotificationCompat.MediaStyle
import io.flutter.plugin.common.MethodChannel
import java.net.URL

class MusicForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "chumian_music_playback"
        const val NOTIFICATION_ID = 1001
        const val ACTION_PLAY = "com.chumian.music.PLAY"
        const val ACTION_PAUSE = "com.chumian.music.PAUSE"
        const val ACTION_NEXT = "com.chumian.music.NEXT"
        const val ACTION_PREVIOUS = "com.chumian.music.PREVIOUS"

        @Volatile
        var methodChannel: MethodChannel? = null

        fun start(context: Context, title: String, artist: String, coverUrl: String?, isPlaying: Boolean) {
            val intent = Intent(context, MusicForegroundService::class.java).apply {
                putExtra("title", title)
                putExtra("artist", artist)
                putExtra("coverUrl", coverUrl)
                putExtra("isPlaying", isPlaying)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, MusicForegroundService::class.java))
        }
    }

    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null
    private var receiver: MusicNotificationReceiver? = null
    private var currentTitle = "初眠音乐"
    private var currentArtist = ""
    private var currentCoverUrl: String? = null
    private var currentIsPlaying = true

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()

        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "ChumianMusic:WakeLock").apply {
            setReferenceCounted(false)
            acquire(30 * 60 * 1000L)
        }

        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        wifiLock = wifiManager.createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "ChumianMusic:WifiLock").apply {
            setReferenceCounted(false)
            acquire()
        }

        receiver = MusicNotificationReceiver()
        val filter = IntentFilter().apply {
            addAction(ACTION_PLAY)
            addAction(ACTION_PAUSE)
            addAction(ACTION_NEXT)
            addAction(ACTION_PREVIOUS)
        }
        registerReceiver(receiver, filter)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        currentTitle = intent?.getStringExtra("title") ?: "初眠音乐"
        currentArtist = intent?.getStringExtra("artist") ?: ""
        currentCoverUrl = intent?.getStringExtra("coverUrl")
        currentIsPlaying = intent?.getBooleanExtra("isPlaying", true) ?: true

        val notification = buildNotification(currentTitle, currentArtist, null, currentIsPlaying)
        startForeground(NOTIFICATION_ID, notification)

        // 后台下载封面后更新通知
        if (!currentCoverUrl.isNullOrEmpty()) {
            Thread {
                try {
                    val url = URL(currentCoverUrl)
                    val conn = url.openConnection()
                    conn.connectTimeout = 5000
                    conn.readTimeout = 5000
                    val bitmap = BitmapFactory.decodeStream(conn.getInputStream())
                    if (bitmap != null) {
                        val updated = buildNotification(currentTitle, currentArtist, bitmap, currentIsPlaying)
                        startForeground(NOTIFICATION_ID, updated)
                    }
                } catch (_: Exception) {}
            }.start()
        }

        return START_STICKY
    }

    private fun buildNotification(title: String, artist: String, largeIcon: Bitmap?, isPlaying: Boolean): Notification {
        val contentIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val playPauseIcon = if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play
        val playPauseAction = NotificationCompat.Action(
            playPauseIcon, if (isPlaying) "暂停" else "播放",
            getPendingIntent(if (isPlaying) ACTION_PAUSE else ACTION_PLAY)
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_media_play)
            .setContentTitle(title)
            .setContentText(artist)
            .setContentIntent(contentIntent)
            .setOngoing(isPlaying)
            .addAction(android.R.drawable.ic_media_previous, "上一首", getPendingIntent(ACTION_PREVIOUS))
            .addAction(playPauseAction)
            .addAction(android.R.drawable.ic_media_next, "下一首", getPendingIntent(ACTION_NEXT))
            .setStyle(
                MediaStyle()
                    .setShowActionsInCompactView(0, 1, 2)
            )

        if (largeIcon != null) {
            builder.setLargeIcon(largeIcon)
        }

        return builder.build()
    }

    private fun getPendingIntent(action: String): PendingIntent {
        val intent = Intent(action).setPackage(packageName)
        return PendingIntent.getBroadcast(
            this, action.hashCode(), intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, "音乐播放",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "初眠音乐播放控制"
                setShowBadge(false)
            }
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try { wakeLock?.release() } catch (_: Exception) {}
        try { wifiLock?.release() } catch (_: Exception) {}
        try { receiver?.let { unregisterReceiver(it) } } catch (_: Exception) {}
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
