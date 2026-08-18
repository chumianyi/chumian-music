package com.chumian.chumian_music

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.chumian.music/player"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        MusicForegroundService.methodChannel = channel

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startForeground" -> {
                    val title = call.argument<String>("title") ?: "初眠音乐"
                    val artist = call.argument<String>("artist") ?: ""
                    val coverUrl = call.argument<String>("coverUrl")
                    val isPlaying = call.argument<Boolean>("isPlaying") ?: true
                    MusicForegroundService.start(this, title, artist, coverUrl, isPlaying)
                    result.success(null)
                }
                "updateNotification" -> {
                    val title = call.argument<String>("title") ?: "初眠音乐"
                    val artist = call.argument<String>("artist") ?: ""
                    val coverUrl = call.argument<String>("coverUrl")
                    val isPlaying = call.argument<Boolean>("isPlaying") ?: true
                    val intent = Intent(this, MusicForegroundService::class.java).apply {
                        putExtra("title", title)
                        putExtra("artist", artist)
                        putExtra("coverUrl", coverUrl)
                        putExtra("isPlaying", isPlaying)
                    }
                    startService(intent)
                    result.success(null)
                }
                "stopForeground" -> {
                    MusicForegroundService.stop(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
