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
import androidx.core.content.ContextCompat
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import com.google.gson.reflect.TypeToken
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
        const val KEY_WEATHER_CODE = "weather_code"
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
    context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int
) {
    // Get reference to SharedPreferences.
    val widgetData: SharedPreferences = HomeWidgetPlugin.getData(context)
    val views: RemoteViews = RemoteViews(
        context.packageName,
        R.layout.weather_widget,
    ).apply {
        // Common view setup
        // Open App on Widget Click.
        val pendingIntent: PendingIntent = HomeWidgetLaunchIntent.getActivity(
            context, MainActivity::class.java
        )
        setOnClickPendingIntent(
            R.id.widget_container,
            pendingIntent,
        )

        // Bind basic weather data
        setTextViewText(
            R.id.text_emoji, widgetData.getString(
                WeatherWidget.KEY_EMOJI,
                "",
            )
        )
        setTextViewText(
            R.id.text_location, widgetData.getString(
                WeatherWidget.KEY_TEXT_LOCATION,
                "",
            )
        )
        setTextViewText(
            R.id.text_temperature, widgetData.getString(
                WeatherWidget.KEY_TEXT_TEMPERATURE,
                "",
            )
        )
        setTextViewText(
            R.id.text_outfit_recommendation, widgetData.getString(
                WeatherWidget.KEY_TEXT_RECOMMENDATION,
                "",
            )
        )
        setTextViewText(
            R.id.text_last_updated, widgetData.getString(
                WeatherWidget.KEY_TEXT_LAST_UPDATED,
                "",
            )
        )

        // Apply background based on weather code.
        val weatherCode: Int = widgetData.getInt(
            WeatherWidget.KEY_WEATHER_CODE,
            -1,
        )
        if (weatherCode != -1) {
            val backgroundResId: Int = getBackgroundResource(weatherCode)
            setInt(
                R.id.widget_container,
                "setBackgroundResource",
                backgroundResId
            )

            // Ensure text is readable on colored backgrounds.
            val textColor: Int = ContextCompat.getColor(
                context,
                android.R.color.white,
            )
            setTextColor(R.id.text_location, textColor)
            setTextColor(R.id.text_temperature, textColor)
            setTextColor(R.id.text_outfit_recommendation, textColor)
            setTextColor(R.id.text_last_updated, textColor)

            // Forecast items text colors
            setTextColor(R.id.forecast_morning_time, textColor)
            setTextColor(R.id.forecast_morning_temp, textColor)
            setTextColor(R.id.forecast_lunch_time, textColor)
            setTextColor(R.id.forecast_lunch_temp, textColor)
            setTextColor(R.id.forecast_evening_time, textColor)
            setTextColor(R.id.forecast_evening_temp, textColor)
        }

        // Bind image.
        val imagePath: String? = widgetData.getString(
            WeatherWidget.KEY_IMAGE_WEATHER,
            null,
        )

        val imageFile: File? = imagePath?.takeIf {
            it.isNotEmpty()
        }?.let { path: String ->
            File(path)
        }
        val isImageAvailable: Boolean = imageFile?.exists() == true

        if (isImageAvailable) {
            @Suppress("UNNECESSARY_SAFE_CALL")
            imageFile?.let { file: File ->
                val bitmap: android.graphics.Bitmap? =
                    BitmapFactory.decodeFile(file.absolutePath)
                bitmap?.let { bmp: android.graphics.Bitmap ->
                    setImageViewBitmap(
                        R.id.image_weather,
                        bmp,
                    )
                    setViewVisibility(
                        R.id.image_weather,
                        View.VISIBLE,
                    )
                }
            }
        } else {
            setViewVisibility(R.id.image_weather, View.GONE)
        }

        // Parse and display forecast data
        val forecastJson: String? = widgetData.getString(
            WeatherWidget.KEY_FORECAST_DATA,
            null,
        )

        // Retrieve selected language for localization (saved from Flutter)
        val languageCode: String = widgetData.getString(
            "selected_language",
            "en",
        ) ?: "en"

        if (forecastJson != null) {
            val gson = Gson()
            val forecastDataType: java.lang.reflect.Type =
                object : TypeToken<ForecastData>() {}.type

            val forecastData: ForecastData? = gson.fromJson(
                forecastJson,
                forecastDataType,
            )

            forecastData?.forecast?.let { forecastList: List<ForecastItem> ->

                if (forecastList.isNotEmpty()) {
                    // Make forecast container visible.
                    setViewVisibility(
                        R.id.forecast_container,
                        View.VISIBLE,
                    )

                    // Sort the forecast list chronologically by time.
                    val sortedForecast: List<ForecastItem> =
                        forecastList.sortedBy { it.time }

                    // Morning slot
                    bindForecastItem(
                        context,
                        this,
                        sortedForecast.getOrNull(0),
                        R.id.forecast_morning_time,
                        R.id.forecast_morning_emoji,
                        R.id.forecast_morning_temp,
                        languageCode,
                    )
                    // Lunch slot
                    bindForecastItem(
                        context,
                        this,
                        sortedForecast.getOrNull(1),
                        R.id.forecast_lunch_time,
                        R.id.forecast_lunch_emoji,
                        R.id.forecast_lunch_temp,
                        languageCode,
                    )
                    // Evening slot
                    bindForecastItem(
                        context,
                        this,
                        sortedForecast.getOrNull(2),
                        R.id.forecast_evening_time,
                        R.id.forecast_evening_emoji,
                        R.id.forecast_evening_temp,
                        languageCode,
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

private fun getBackgroundResource(code: Int): Int {
    return when (code) {
        0 -> R.drawable.widget_background_sunny
        1, 2, 3, 45, 48 -> R.drawable.widget_background_cloudy
        51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 95, 96, 99 ->
            R.drawable.widget_background_rainy

        71, 73, 75, 77, 85, 86 -> R.drawable.widget_background_snowy
        else -> R.drawable.widget_background
    }
}

private fun bindForecastItem(
    context: Context,
    views: RemoteViews,
    item: ForecastItem?,
    timeId: Int,
    emojiId: Int,
    tempId: Int,
    languageCode: String
) {
    if (item != null) {
        val date: Date? = parseDate(item.time)
        if (date != null) {
            views.setTextViewText(
                timeId,
                getTimeOfDay(context, date, languageCode),
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

private val dateParser: SimpleDateFormat = SimpleDateFormat(
    "yyyy-MM-dd'T'HH:mm",
    Locale.US,
)

private fun parseDate(dateString: String): Date? = try {
    dateParser.parse(dateString)
} catch (e: Exception) {
    e.printStackTrace()
    null
}


// Create a localized context for resource lookups based on the provided
// language code.
private fun getLocalizedContext(
    context: Context,
    languageCode: String
): Context {
    // Use forLanguageTag for standard BCP 47 tags (e.g., "en", "uk").
    val locale: Locale = Locale.forLanguageTag(languageCode)
    Locale.setDefault(locale)
    val config: android.content.res.Configuration =
        android.content.res.Configuration(
            context.resources.configuration,
        )
    config.setLocale(locale)

    // `createConfigurationContext` is safe and will NOT crash the widget.
    // It is specifically designed to create a Context with overridden
    // resources.
    return context.createConfigurationContext(config)
}

private fun getTimeOfDay(
    context: Context,
    date: Date,
    languageCode: String
): String {
    val localizedContext: Context = getLocalizedContext(context, languageCode)
    val cal: Calendar = Calendar.getInstance()
    cal.time = date
    return when (cal.get(Calendar.HOUR_OF_DAY)) {
        in 5..11 -> localizedContext.getString(R.string.morning)
        in 12..16 -> localizedContext.getString(R.string.lunch)
        in 17..21 -> localizedContext.getString(R.string.evening)
        else -> localizedContext.getString(R.string.night)
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
