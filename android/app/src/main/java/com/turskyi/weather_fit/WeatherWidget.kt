package com.turskyi.weather_fit

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import com.google.gson.reflect.TypeToken
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_EMOJI
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_FORECAST_DATA
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_IMAGE_WEATHER
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_TEXT_LAST_UPDATED
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_TEXT_LOCATION
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_TEXT_RECOMMENDATION
import com.turskyi.weather_fit.WeatherWidget.Companion.KEY_TEXT_TEMPERATURE
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

// Data class to match the JSON structure.
data class ForecastItem(
    val time: String,
    val temperature: Double,
    @SerializedName("weather_code") val weatherCode: Int
)

data class ForecastData(val forecast: List<ForecastItem>)

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
        const val KEY_FORECAST_DATA = "forecast_data"
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
    val views: RemoteViews =
        RemoteViews(
            context.packageName,
            R.layout.weather_widget,
        ).apply {
            // Common view setup
            // Open App on Widget Click.
            val pendingIntent: PendingIntent =
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
            setOnClickPendingIntent(
                R.id.widget_container,
                pendingIntent,
            )

            // Bind basic weather data
            setTextViewText(
                R.id.text_emoji,
                widgetData.getString(KEY_EMOJI, "")
            )
            setTextViewText(
                R.id.text_location,
                widgetData.getString(KEY_TEXT_LOCATION, "")
            )
            setTextViewText(
                R.id.text_temperature,
                widgetData.getString(KEY_TEXT_TEMPERATURE, "")
            )
            setTextViewText(
                R.id.text_outfit_recommendation,
                widgetData.getString(
                    KEY_TEXT_RECOMMENDATION,
                    "",
                )
            )
            setTextViewText(
                R.id.text_last_updated,
                widgetData.getString(KEY_TEXT_LAST_UPDATED, "")
            )

            // Bind image
            val imagePath: String? =
                widgetData.getString(KEY_IMAGE_WEATHER, null)
            // Get image and put it in the widget if it exists.
            if (!imagePath.isNullOrEmpty() && File(imagePath).exists()) {
                val bitmap: android.graphics.Bitmap? =
                    BitmapFactory.decodeFile(
                        File(imagePath).absolutePath,
                    )
                if (bitmap != null) {
                    setImageViewBitmap(R.id.image_weather, bitmap)
                }
            }

            // Parse and display forecast data
            val forecastJson: String? =
                widgetData.getString(KEY_FORECAST_DATA, null)

            if (forecastJson != null) {
                val gson = Gson()
                val forecastDataType: java.lang.reflect.Type =
                    object : TypeToken<ForecastData>() {}.type

                val forecastData: ForecastData? =
                    gson.fromJson(forecastJson, forecastDataType)

                forecastData?.forecast?.let { forecastList: List<ForecastItem> ->

                    if (forecastList.isNotEmpty()) {
                        // Make forecast container visible.
                        setViewVisibility(
                            R.id.forecast_container,
                            View.VISIBLE,
                        )
                        // Morning
                        bindForecastItem(
                            context,
                            this,
                            forecastList.getOrNull(0),
                            R.id.forecast_morning_day,
                            R.id.forecast_morning_time,
                            R.id.forecast_morning_emoji,
                            R.id.forecast_morning_temp
                        )
                        // Lunch
                        bindForecastItem(
                            context,
                            this,
                            forecastList.getOrNull(1),
                            R.id.forecast_lunch_day,
                            R.id.forecast_lunch_time,
                            R.id.forecast_lunch_emoji,
                            R.id.forecast_lunch_temp
                        )
                        // Evening
                        bindForecastItem(
                            context,
                            this,
                            forecastList.getOrNull(2),
                            R.id.forecast_evening_day,
                            R.id.forecast_evening_time,
                            R.id.forecast_evening_emoji,
                            R.id.forecast_evening_temp
                        )
                    } else {
                        setViewVisibility(
                            R.id.forecast_container,
                            View.GONE,
                        )
                    }
                }
            } else {
                setViewVisibility(
                    R.id.forecast_container,
                    View.GONE,
                )
            }
        }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

private fun bindForecastItem(
    context: Context,
    views: RemoteViews,
    item: ForecastItem?,
    dayId: Int,
    timeId: Int,
    emojiId: Int,
    tempId: Int
) {
    if (item != null) {
        val date: Date? = parseDate(item.time)
        if (date != null) {
            views.setTextViewText(dayId, getDay(context, date))
            views.setTextViewText(
                timeId,
                getTimeOfDay(context, date),
            )
            views.setTextViewText(
                emojiId,
                getWeatherEmoji(item.weatherCode),
            )
            views.setTextViewText(
                tempId,
                "${item.temperature.toInt()}°",
            )
        }
    }
}

private val dateParser = SimpleDateFormat(
    "yyyy-MM-dd'T'HH:mm",
    Locale.US,
)

private fun parseDate(dateString: String): Date? = try {
    dateParser.parse(dateString)
} catch (e: Exception) {
    e.printStackTrace()
    null
}

private fun getDay(context: Context, date: Date): String {
    val cal: Calendar = Calendar.getInstance()
    val today: Int = cal.get(Calendar.DAY_OF_YEAR)
    cal.time = date
    val itemDay: Int = cal.get(Calendar.DAY_OF_YEAR)

    return when (itemDay) {
        today -> context.getString(R.string.today)
        today + 1 -> context.getString(R.string.tomorrow)
        else -> SimpleDateFormat("EEE", Locale.US).format(date)
    }
}

private fun getTimeOfDay(context: Context, date: Date): String {
    val cal: Calendar = Calendar.getInstance()
    cal.time = date
    return when (cal.get(Calendar.HOUR_OF_DAY)) {
        in 5..11 -> context.getString(R.string.morning)
        in 12..16 -> context.getString(R.string.lunch)
        in 17..21 -> context.getString(R.string.evening)
        else -> context.getString(R.string.night)
    }
}

private fun getWeatherEmoji(code: Int): String = when (code) {
    0 -> "☀️"
    1, 2, 3 -> "☁️"
    45, 48 -> "🌫"
    51, 53, 55, 56, 57 -> "💧"
    61, 63, 65, 66, 67 -> "🌧"
    71, 73, 75, 77 -> "❄️"
    80, 81, 82 -> "⛈"
    85, 86 -> "🌨"
    95, 96, 99 -> "🌪"
    else -> "🤔"
}