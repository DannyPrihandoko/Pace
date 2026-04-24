package com.pace.pace

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PaceWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: android.content.SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.pace_widget_layout).apply {
                val title = widgetData.getString("title", "Pace Schedule")
                val upcoming = widgetData.getString("upcoming_activity", "No upcoming activities")
                val time = widgetData.getString("activity_time", "--")

                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_upcoming_activity, upcoming)
                setTextViewText(R.id.widget_time, time)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
