package com.wisnufebri.quran.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import com.wisnufebri.quran.app.R

class PrayerWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_widget).apply {
                // Get data from Flutter
                val city = widgetData.getString("city", "Lokasi...")
                val hijri = widgetData.getString("hijri", "-")
                val prayerName = widgetData.getString("next_prayer_name", "-")
                val prayerTime = widgetData.getString("next_prayer_time", "--:--")

                setTextViewText(R.id.widget_location, city)
                setTextViewText(R.id.widget_hijri, hijri)
                setTextViewText(R.id.widget_next_prayer_name, prayerName)
                setTextViewText(R.id.widget_next_prayer_time, prayerTime)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
