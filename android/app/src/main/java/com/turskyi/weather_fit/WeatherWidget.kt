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
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_EMOJI
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_IMAGE_WEATHER
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_TEXT_LAST_UPDATED
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_TEXT_LOCATION
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_TEXT_RECOMMENDATION
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_TEXT_TEMPERATURE
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

/**
 * Implementation of App Widget functionality.
 */
@SuppressLint("ObsoleteSdkInt")
@RequiresApi(Build.VERSION_CODES.CUPCAKE)
class WeatherWidget : AppWidgetProvider() {
    companion object {
        const val KEY_EMOJI = "text_emoji"
        const val KEY_TEXT_LOCATION = "text_location"
        const val KEY_TEXT_TEMPERATURE = "text_temperature"
        const val KEY_TEXT_LAST_UPDATED = "text_last_updated"
        const val KEY_IMAGE_WEATHER = "image_weather"
        const val KEY_TEXT_RECOMMENDATION = "text_recommendation"

    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {

        // There may be multiple widgets active, so update all of them.
        for (appWidgetId: Int in appWidgetIds) {
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

@RequiresApi(Build.VERSION_CODES.CUPCAKE)
@SuppressLint("ObsoleteSdkInt")
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

        val emoji: String? = widgetData.getString(KEY_EMOJI, null)

        setTextViewText(R.id.text_emoji, emoji ?: "")

        val location: String? = widgetData.getString(
            KEY_TEXT_LOCATION,
            null
        )

        setTextViewText(
            R.id.text_location,
            location ?: "",
        )

        val temperature: String? = widgetData.getString(
            KEY_TEXT_TEMPERATURE,
            null,
        )

        setTextViewText(
            R.id.text_temperature,
            temperature ?: "",
        )

        val recommendation: String? = widgetData.getString(
            KEY_TEXT_RECOMMENDATION,
            null,
        )

        setTextViewText(
            R.id.text_outfit_recommendation,
            recommendation ?: "",
        )

        val lastUpdated: String? = widgetData.getString(
            KEY_TEXT_LAST_UPDATED,
            null,
        )

        setTextViewText(
            R.id.text_last_updated,
            lastUpdated ?: "",
        )

        // Get image and put it in the widget if it exists.
        val imagePath: String? = widgetData.getString(
            KEY_IMAGE_WEATHER,
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
                context.getString(
                    R.string.oops_no_outfit_suggestion_available,
                ),
                context.getString(
                    R.string.looks_like_we_couldn_t_pick_an_outfit_this_time,
                ),
                context.getString(
                    R.string.no_recommendation_time_to_mix_match_your_own_style,
                ),
                context.getString(
                    R.string.your_fashion_instincts_take_the_lead_today,
                ),
                context.getString(
                    R.string.ai_is_taking_a_fashion_break_try_again,
                ),
                context.getString(
                    R.string.no_outfit_picked_maybe_today_is_a_pajama_day,
                ),
                context.getString(R.string.no_outfit_available),
                context.getString(R.string.no_recommendation)
            )
            setTextViewText(
                R.id.text_outfit_recommendation,
                defaultMessages.random(),
            )
        }
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}