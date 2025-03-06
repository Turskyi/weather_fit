package com.turskyi.weather_fit

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

/**
 * Implementation of App Widget functionality.
 */
@SuppressLint("ObsoleteSdkInt")
@RequiresApi(Build.VERSION_CODES.CUPCAKE)
class WeatherWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {

        // There may be multiple widgets active, so update all of them.
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created.
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled.
    }
}

@SuppressLint("ObsoleteSdkInt")
@RequiresApi(Build.VERSION_CODES.CUPCAKE)
internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    // Get reference to SharedPreferences.
    val widgetData: SharedPreferences = HomeWidgetPlugin.getData(context)

    val views: RemoteViews = RemoteViews(
        context.packageName,
        R.layout.weather_widget,
    ).apply {
        // Open App on Widget Click.
        val pendingIntent: PendingIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java
        )

        setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        val emoji: String? = widgetData.getString("text_emoji", null)

        setTextViewText(R.id.text_emoji, emoji ?: "")

        val location: String? = widgetData.getString("text_location", null)

        setTextViewText(
            R.id.text_location,
            location ?: "",
        )

        val temperature: String? = widgetData.getString(
            "text_temperature",
            null,
        )

        setTextViewText(
            R.id.text_temperature,
            temperature ?: "",
        )

        val recommendation: String? = widgetData.getString(
            "text_recommendation",
            null,
        )

        setTextViewText(
            R.id.text_outfit_recommendation,
            recommendation ?: "",
        )

        val lastUpdated: String? = widgetData.getString(
            "text_last_updated",
            null,
        )

        setTextViewText(
            R.id.text_last_updated,
            lastUpdated ?: "",
        )

        // Get image and put it in the widget if it exists.
        val imagePath: String? = widgetData.getString(
            "image_weather",
            null,
        )

        if (!imagePath.isNullOrEmpty()) {
            val imageFile = File(imagePath)
            val imageExists: Boolean = imageFile.exists()

            if (imageExists) {
                val myBitmap: Bitmap? = BitmapFactory.decodeFile(
                    imageFile.absolutePath,
                )

                if (myBitmap != null) {
                    setImageViewBitmap(R.id.image_weather, myBitmap)
                }
            }
        } else if (recommendation.isNullOrEmpty()) {
            // Default messages with emojis.
            val defaultMessages: List<String> = listOf(
                "👕 Oops! No outfit suggestion available.",
                "🤷 Looks like we couldn’t pick an outfit this time.",
                "🎭 No recommendation? Time to mix & match your own style!",
                "💡 Your fashion instincts take the lead today!",
                "🚀 AI is taking a fashion break. Try again!",
                "🛌 No outfit picked—maybe today is a pajama day?",
                "❌ No outfit available",
                "🤔 no recommendation"
            )
            setTextViewText(
                R.id.text_outfit_recommendation,
                defaultMessages.random(),
            )
        }
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}