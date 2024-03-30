package com.turskyi.weather_fit

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

/**
 * Implementation of App Widget functionality.
 */
@SuppressLint("ObsoleteSdkInt")
@TargetApi(Build.VERSION_CODES.CUPCAKE)
class WeatherWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {

        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

@SuppressLint("ObsoleteSdkInt")
@TargetApi(Build.VERSION_CODES.CUPCAKE)
internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    // Get reference to SharedPreferences
    val widgetData: SharedPreferences = HomeWidgetPlugin.getData(context)
    val views: RemoteViews = RemoteViews(context.packageName, R.layout.weather_widget).apply {
        // Open App on Widget Click
        val pendingIntent: PendingIntent =
            HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
        setOnClickPendingIntent(R.id.widget_container, pendingIntent)
        val emoji: String? = widgetData.getString("text_emoji", null)
        setTextViewText(R.id.text_emoji, emoji ?: "No emoji set")

        val location: String? = widgetData.getString("text_location", null)
        setTextViewText(R.id.text_location, location ?: "No location set")

        val temperature: String? = widgetData.getString("text_temperature", null)
        setTextViewText(R.id.text_temperature, temperature ?: "No temperature set")

        val lastUpdated: String? = widgetData.getString("text_last_updated", null)
        setTextViewText(R.id.text_last_updated, lastUpdated ?: "Last updated not set")

        // Get chart image and put it in the widget, if it exists
        val imagePath: String? = widgetData.getString("image_weather", null)
        if (imagePath != null) {
            val imageFile = File(imagePath)
            val imageExists: Boolean = imageFile.exists()
            if (imageExists) {
                val myBitmap: Bitmap? = BitmapFactory.decodeFile(imageFile.absolutePath)
                if (myBitmap != null) {
                    setImageViewBitmap(R.id.image_weather, myBitmap)
                }
            }
        }
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}