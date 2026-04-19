package com.turskyi.weather_fit

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Shader
import android.os.Build
import android.util.DisplayMetrics
import android.util.TypedValue
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
import kotlin.math.max
import kotlin.math.roundToInt
import kotlin.math.sqrt

private const val MAX_CONSTRAINED_WIDGET_BITMAP_BYTES = 760 * 1024
private const val FALLBACK_WIDGET_SIZE_DP = 220

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
        const val KEY_TEXT_LOCATION = "text_location"
        const val KEY_TEXT_TEMPERATURE = "text_temperature"
        const val KEY_IMAGE_WEATHER = "image_weather"
        const val KEY_FORECAST_DATA = "forecast_data"
        const val KEY_WEATHER_CODE = "weather_code"
        const val KEY_EMOJI = "weatherfit_text_emoji"
        const val KEY_TEXT_LAST_UPDATED = "weatherfit_text_last_updated"
        const val KEY_TEXT_RECOMMENDATION = "weatherfit_text_recommendation"
        const val KEY_IS_WEATHER_BACKGROUND_ENABLED = "weatherfit_is_weather_background_enabled"
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
    appWidgetId: Int,
    useConstrainedImage: Boolean = false,
    includeImage: Boolean = true,
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
            val isWeatherBackgroundEnabled = widgetData.getBoolean(
                WeatherWidget.KEY_IS_WEATHER_BACKGROUND_ENABLED,
                false
            )
            val widgetSizePx: Pair<Int, Int> = getWidgetSizePx(
                context,
                appWidgetManager,
                appWidgetId,
            )

            // Generate 4-color gradient background
            val isNight = isNight()
            val gradientBitmap = generateGradientBitmap(
                width = widgetSizePx.first,
                height = widgetSizePx.second,
                weatherCode = weatherCode,
                isNight = isNight
            )
            setImageViewBitmap(R.id.image_background, gradientBitmap)

            // Pattern Overlay
            if (isWeatherBackgroundEnabled) {
                val emoji = widgetData.getString(WeatherWidget.KEY_EMOJI, "☀️") ?: "☀️"
                val patternBitmap = generatePatternBitmap(
                    width = widgetSizePx.first,
                    height = widgetSizePx.second,
                    emoji = emoji,
                    isNight = isNight
                )
                setImageViewBitmap(R.id.image_pattern, patternBitmap)
                setViewVisibility(R.id.image_pattern, View.VISIBLE)
            } else {
                setViewVisibility(R.id.image_pattern, View.GONE)
            }

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

        if (isImageAvailable && includeImage) {
            @Suppress("UNNECESSARY_SAFE_CALL")
            imageFile?.let { file: File ->
                val bitmap: Bitmap? = decodeWidgetBitmap(
                    context,
                    appWidgetManager,
                    appWidgetId,
                    file.absolutePath,
                    useConstrainedImage,
                )
                bitmap?.let { bmp: Bitmap ->
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

    try {
        appWidgetManager.updateAppWidget(appWidgetId, views)
    } catch (exception: IllegalArgumentException) {
        val isBitmapLimitException: Boolean =
            exception.message?.contains("exceeds maximum bitmap memory usage") == true
        if (isBitmapLimitException && includeImage && !useConstrainedImage) {
            updateAppWidget(
                context,
                appWidgetManager,
                appWidgetId,
                useConstrainedImage = true,
                includeImage = true,
            )
        } else if (isBitmapLimitException && includeImage && useConstrainedImage) {
            updateAppWidget(
                context,
                appWidgetManager,
                appWidgetId,
                useConstrainedImage = false,
                includeImage = false,
            )
        } else {
            throw exception
        }
    }
}

private fun decodeWidgetBitmap(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int,
    path: String,
    useConstrainedImage: Boolean,
): Bitmap? {
    val boundsOptions: BitmapFactory.Options = BitmapFactory.Options().apply {
        inJustDecodeBounds = true
    }
    BitmapFactory.decodeFile(path, boundsOptions)

    val widgetSizePx: Pair<Int, Int> = getWidgetSizePx(
        context,
        appWidgetManager,
        appWidgetId,
    )

    val sampleSize: Int = calculateSampleSize(
        boundsOptions.outWidth,
        boundsOptions.outHeight,
        widgetSizePx.first,
        widgetSizePx.second,
    )

    val decodeOptions: BitmapFactory.Options = BitmapFactory.Options().apply {
        inSampleSize = sampleSize
        inPreferredConfig = if (useConstrainedImage) {
            Bitmap.Config.RGB_565
        } else {
            Bitmap.Config.ARGB_8888
        }
    }

    val decodedBitmap: Bitmap? = BitmapFactory.decodeFile(path, decodeOptions)
    return decodedBitmap?.let { bitmap: Bitmap ->
        if (useConstrainedImage) {
            downscaleToByteLimit(bitmap, MAX_CONSTRAINED_WIDGET_BITMAP_BYTES)
        } else {
            bitmap
        }
    }
}

private fun getWidgetSizePx(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int,
): Pair<Int, Int> {
    val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
    val minWidthDp: Int = options.getInt(
        AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH,
        FALLBACK_WIDGET_SIZE_DP,
    )
    val minHeightDp: Int = options.getInt(
        AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT,
        FALLBACK_WIDGET_SIZE_DP,
    )
    val widthPx: Int = dpToPx(context.resources.displayMetrics, minWidthDp)
    val heightPx: Int = dpToPx(context.resources.displayMetrics, minHeightDp)

    return Pair(
        max(widthPx, dpToPx(context.resources.displayMetrics, FALLBACK_WIDGET_SIZE_DP)),
        max(heightPx, dpToPx(context.resources.displayMetrics, FALLBACK_WIDGET_SIZE_DP)),
    )
}

private fun dpToPx(metrics: DisplayMetrics, dp: Int): Int {
    return TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP,
        dp.toFloat(),
        metrics,
    ).roundToInt()
}

private fun calculateSampleSize(
    sourceWidth: Int,
    sourceHeight: Int,
    targetWidth: Int,
    targetHeight: Int,
): Int {
    if (sourceWidth <= 0 || sourceHeight <= 0) {
        return 1
    } else {
        var inSampleSize = 1
        if (sourceHeight > targetHeight || sourceWidth > targetWidth) {
            var halfHeight = sourceHeight / 2
            var halfWidth = sourceWidth / 2
            while (
                halfHeight / inSampleSize >= targetHeight &&
                halfWidth / inSampleSize >= targetWidth
            ) {
                inSampleSize *= 2
            }
        }
        return max(1, inSampleSize)
    }
}

private fun downscaleToByteLimit(
    bitmap: Bitmap,
    maxBytes: Int,
): Bitmap {
    val currentBytes: Int = bitmap.allocationByteCount
    if (currentBytes <= maxBytes) {
        return bitmap
    } else {
        val scale: Double = sqrt(maxBytes.toDouble() / currentBytes.toDouble())
        val scaledWidth: Int = max(1, (bitmap.width * scale).roundToInt())
        val scaledHeight: Int = max(1, (bitmap.height * scale).roundToInt())
        val scaledBitmap: Bitmap = Bitmap.createScaledBitmap(
            bitmap,
            scaledWidth,
            scaledHeight,
            true,
        )
        if (scaledBitmap != bitmap) {
            bitmap.recycle()
        }
        return scaledBitmap
    }
}

private fun isNight(): Boolean {
    val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
    return hour < 6 || hour >= 21
}

private fun generateGradientBitmap(
    width: Int,
    height: Int,
    weatherCode: Int,
    isNight: Boolean
): Bitmap {
    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)

    val colors = getGradientColors(weatherCode, isNight)
    val shader = LinearGradient(
        0f, 0f, 0f, height.toFloat(),
        colors,
        floatArrayOf(0.0f, 0.35f, 0.65f, 1.0f),
        Shader.TileMode.CLAMP
    )

    val paint = Paint().apply {
        this.shader = shader
    }

    canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)
    return bitmap
}

private fun getGradientColors(code: Int, isNight: Boolean): IntArray {
    return when {
        code == 0 || code == 800 -> { // Sunny
            if (isNight) {
                intArrayOf(
                    Color.parseColor("#1A1A33"),
                    Color.parseColor("#0D0D1A"),
                    Color.parseColor("#05050D"),
                    Color.parseColor("#000005")
                )
            } else {
                intArrayOf(
                    Color.parseColor("#FFCC33"),
                    Color.parseColor("#FF9900"),
                    Color.parseColor("#E66600"),
                    Color.parseColor("#CC4D00")
                )
            }
        }
        (code in 1..3) || code == 45 || code == 48 || (code in 701..799) || (code in 801..804) -> { // Cloudy
            if (isNight) {
                intArrayOf(
                    Color.parseColor("#262633"),
                    Color.parseColor("#1A1A26"),
                    Color.parseColor("#0D0D1A"),
                    Color.parseColor("#05050D")
                )
            } else {
                intArrayOf(
                    Color.parseColor("#99B2CC"),
                    Color.parseColor("#8099B2"),
                    Color.parseColor("#668099"),
                    Color.parseColor("#4D6680")
                )
            }
        }
        (code in 51..67) || (code in 80..82) || (code in 95..99) || (code in 200..599) -> { // Rain
            if (isNight) {
                intArrayOf(
                    Color.parseColor("#1A2640"),
                    Color.parseColor("#0D1A33"),
                    Color.parseColor("#050D26"),
                    Color.parseColor("#00051A")
                )
            } else {
                intArrayOf(
                    Color.parseColor("#4D6699"),
                    Color.parseColor("#334D80"),
                    Color.parseColor("#1A3366"),
                    Color.parseColor("#0D1A4D")
                )
            }
        }
        (code in 71..77) || (code in 85..86) || (code in 600..699) -> { // Snow
            if (isNight) {
                intArrayOf(
                    Color.parseColor("#33334D"),
                    Color.parseColor("#262640"),
                    Color.parseColor("#1A1A33"),
                    Color.parseColor("#0D0D26")
                )
            } else {
                intArrayOf(
                    Color.parseColor("#D9E6FF"),
                    Color.parseColor("#BFCCFF"),
                    Color.parseColor("#A6B2CC"),
                    Color.parseColor("#8C99B2")
                )
            }
        }
        else -> {
            if (isNight) {
                intArrayOf(
                    Color.parseColor("#1A0D33"),
                    Color.parseColor("#0D0526"),
                    Color.parseColor("#05031A"),
                    Color.parseColor("#03000D")
                )
            } else {
                intArrayOf(
                    Color.parseColor("#4B0082"), // Indigo
                    Color.parseColor("#800080"), // Purple
                    Color.parseColor("#0000FF"), // Blue
                    Color.parseColor("#00FFFF")  // Cyan
                )
            }
        }
    }
}

private fun generatePatternBitmap(
    width: Int,
    height: Int,
    emoji: String,
    isNight: Boolean
): Bitmap {
    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        textSize = 60f
        textAlign = Paint.Align.CENTER
        alpha = if (isNight) (0.07f * 255).toInt() else (0.22f * 255).toInt()
    }

    val step = 120f
    val cols = (width / step).toInt() + 1
    val rows = (height / step).toInt() + 1
    for (y in 0 until rows) {
        for (x in 0 until cols) {
            canvas.save()
            val tx = x * step + step / 2f
            val ty = y * step + step / 2f
            canvas.translate(tx, ty)
            canvas.rotate(if ((x + y) % 2 == 0) 15f else -15f)
            canvas.drawText(emoji, 0f, 0f, paint)
            canvas.restore()
        }
    }

    return bitmap
}

private fun getBackgroundResource(code: Int): Int {
    return when {
        code == 0 || code == 800 -> R.drawable.widget_background_sunny
        (code in 1..3) || code == 45 || code == 48 || (code in 700..799) || (code in 801..804) ->
            R.drawable.widget_background_cloudy

        (code in 51..67) || (code in 80..82) || (code in 95..99) || (code in 200..599) ->
            R.drawable.widget_background_rainy

        (code in 71..77) || (code in 85..86) || (code in 600..699) ->
            R.drawable.widget_background_snowy

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

private fun getWeatherEmoji(code: Int): String = when {
    code == 0 || code == 800 -> "☀️"
    (code in 1..3) || (code in 801..804) -> "☁️"
    code == 45 || code == 48 || (code in 700..799) -> "🌫"
    (code in 51..57) || (code in 200..599) -> "🌧"
    code in 61..67 -> "🌧"
    (code in 71..77) || (code in 600..699) -> "❄️"
    code in 80..82 -> "🌧"
    code in 85..86 -> "🌨"
    code in 95..99 -> "⛈"
    else -> ""
}
