package com.pace.pace

import android.appwidget.AppWidgetManager
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PaceWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: android.content.SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.pace_widget_layout).apply {
                
                // Activity 1
                val title1 = widgetData.getString("upcoming_1_title", "")
                val time1 = widgetData.getString("upcoming_1_time", "--")
                val category1 = widgetData.getString("upcoming_1_category", "P")

                if (title1.isNullOrEmpty() || title1 == "No more tasks today") {
                    setTextViewText(R.id.widget_title_1, "No tasks left")
                    setTextViewText(R.id.widget_time_1, "--")
                    setTextViewText(R.id.widget_icon_1, "✓")
                    setViewVisibility(R.id.widget_item_2, View.GONE)
                } else {
                    setTextViewText(R.id.widget_title_1, title1)
                    setTextViewText(R.id.widget_time_1, time1)
                    setTextViewText(R.id.widget_icon_1, category1?.take(1)?.uppercase() ?: "P")
                    
                    // Activity 2
                    val title2 = widgetData.getString("upcoming_2_title", "")
                    val time2 = widgetData.getString("upcoming_2_time", "")
                    val category2 = widgetData.getString("upcoming_2_category", "P")

                    if (title2.isNullOrEmpty()) {
                        setViewVisibility(R.id.widget_item_2, View.GONE)
                    } else {
                        setViewVisibility(R.id.widget_item_2, View.VISIBLE)
                        setTextViewText(R.id.widget_title_2, title2)
                        setTextViewText(R.id.widget_time_2, time2)
                        setTextViewText(R.id.widget_icon_2, category2?.take(1)?.uppercase() ?: "P")
                    }
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
