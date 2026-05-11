package com.wisnufebri.quran.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetProvider
import com.wisnufebri.quran.app.R
import android.view.KeyEvent
import com.ryanheise.audioservice.MediaButtonReceiver

class MurattalWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.murattal_widget).apply {
                // Get data from Flutter
                val surahName = widgetData.getString("surah_name", "Belum Memutar")
                val isPlaying = widgetData.getBoolean("is_playing", false)
                val progress = widgetData.getInt("playback_progress", 0)

                setTextViewText(R.id.widget_surah_name, surahName)
                setTextViewText(R.id.widget_status, if (isPlaying) "Sedang Memutar" else "Berhenti")
                setProgressBar(R.id.widget_progress, 100, progress, false)
                setImageViewResource(
                    R.id.widget_play_pause,
                    if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play
                )

                // Send media key events directly to AudioService, so controls work
                // from the home-screen widget without launching MainActivity.
                val prevIntent = createMediaButtonIntent(
                    context = context,
                    keyCode = KeyEvent.KEYCODE_MEDIA_PREVIOUS,
                    requestCode = widgetId * 10 + 1
                )
                val playPauseIntent = createMediaButtonIntent(
                    context = context,
                    keyCode = KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE,
                    requestCode = widgetId * 10 + 2
                )
                val nextIntent = createMediaButtonIntent(
                    context = context,
                    keyCode = KeyEvent.KEYCODE_MEDIA_NEXT,
                    requestCode = widgetId * 10 + 3
                )

                setOnClickPendingIntent(R.id.widget_prev, prevIntent)
                setOnClickPendingIntent(R.id.widget_play_pause, playPauseIntent)
                setOnClickPendingIntent(R.id.widget_next, nextIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun createMediaButtonIntent(
        context: Context,
        keyCode: Int,
        requestCode: Int
    ): PendingIntent {
        val intent = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
            setClass(context, MediaButtonReceiver::class.java)
            putExtra(
                Intent.EXTRA_KEY_EVENT,
                KeyEvent(KeyEvent.ACTION_DOWN, keyCode)
            )
        }

        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}
