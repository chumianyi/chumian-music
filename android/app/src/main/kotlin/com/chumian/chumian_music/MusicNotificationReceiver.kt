package com.chumian.chumian_music

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class MusicNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val channel = MusicForegroundService.methodChannel ?: return
        when (intent?.action) {
            MusicForegroundService.ACTION_PLAY -> channel.invokeMethod("onPlay", null)
            MusicForegroundService.ACTION_PAUSE -> channel.invokeMethod("onPause", null)
            MusicForegroundService.ACTION_NEXT -> channel.invokeMethod("onNext", null)
            MusicForegroundService.ACTION_PREVIOUS -> channel.invokeMethod("onPrevious", null)
        }
    }
}
