package com.turskyi.weather_fit.glance

import android.content.Context
import android.graphics.Color
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture
import es.antonborri.home_widget.HomeWidgetPlugin

class WeatherTileService : androidx.wear.tiles.TileService() {
    override fun onTileRequest(
        requestParams: androidx.wear.tiles.RequestBuilders.TileRequest
    ): ListenableFuture<androidx.wear.tiles.TileBuilders.Tile> {
        android.util.Log.d("WeatherFitTile", "onTileRequest: Loading tile layout")
        
        val weather = try {
            WeatherTileData.from(this)
        } catch (e: Throwable) {
            android.util.Log.e("WeatherFitTile", "onTileRequest: Failed to load data", e)
            WeatherTileData.empty()
        }

        val tile = androidx.wear.tiles.TileBuilders.Tile.Builder()
            .setResourcesVersion("1")
            .setTileTimeline(
                androidx.wear.protolayout.TimelineBuilders.Timeline.Builder()
                    .addTimelineEntry(
                        androidx.wear.protolayout.TimelineBuilders.TimelineEntry.Builder()
                            .setLayout(
                                androidx.wear.protolayout.LayoutElementBuilders.Layout.Builder()
                                    .setRoot(createTileLayout(weather))
                                    .build()
                            )
                            .build()
                    )
                    .build()
            )
            .build()
        return Futures.immediateFuture(tile)
    }

    override fun onTileResourcesRequest(
        requestParams: androidx.wear.tiles.RequestBuilders.ResourcesRequest
    ): ListenableFuture<androidx.wear.protolayout.ResourceBuilders.Resources> {
        return Futures.immediateFuture(
            androidx.wear.protolayout.ResourceBuilders.Resources.Builder().setVersion("1").build()
        )
    }

    private fun createTileLayout(weather: WeatherTileData): androidx.wear.protolayout.LayoutElementBuilders.LayoutElement {
        val primaryColor = if (weather.hasWeather) weather.backgroundColor else Color.YELLOW

        return androidx.wear.protolayout.LayoutElementBuilders.Box.Builder()
            .setWidth(androidx.wear.protolayout.DimensionBuilders.expand())
            .setHeight(androidx.wear.protolayout.DimensionBuilders.expand())
            .setModifiers(
                androidx.wear.protolayout.ModifiersBuilders.Modifiers.Builder()
                    .setClickable(
                        androidx.wear.protolayout.ModifiersBuilders.Clickable.Builder()
                            .setId("open_app")
                            .setOnClick(
                                androidx.wear.protolayout.ActionBuilders.LaunchAction.Builder()
                                    .setAndroidActivity(
                                        androidx.wear.protolayout.ActionBuilders.AndroidActivity.Builder()
                                            .setPackageName(this.packageName)
                                            .setClassName("com.turskyi.weather_fit.MainActivity")
                                            .build()
                                    )
                                    .build()
                            )
                            .build()
                    )
                    .build()
            )
            .addContent(
                androidx.wear.protolayout.LayoutElementBuilders.Column.Builder()
                    .setWidth(androidx.wear.protolayout.DimensionBuilders.expand())
                    .setHorizontalAlignment(androidx.wear.protolayout.LayoutElementBuilders.HORIZONTAL_ALIGN_CENTER)
                    .addContent(
                        androidx.wear.protolayout.LayoutElementBuilders.Text.Builder()
                            .setText(if (weather.hasWeather) weather.location else "WeatherFit")
                            .setFontStyle(
                                androidx.wear.protolayout.LayoutElementBuilders.FontStyle.Builder()
                                    .setSize(androidx.wear.protolayout.DimensionBuilders.sp(16f))
                                    .setColor(androidx.wear.protolayout.ColorBuilders.argb(Color.LTGRAY))
                                    .setWeight(androidx.wear.protolayout.LayoutElementBuilders.FONT_WEIGHT_BOLD)
                                    .build()
                            )
                            .build()
                    )
                    .addContent(
                        androidx.wear.protolayout.LayoutElementBuilders.Text.Builder()
                            .setText(if (weather.hasWeather) weather.emoji else "☀️")
                            .setFontStyle(
                                androidx.wear.protolayout.LayoutElementBuilders.FontStyle.Builder()
                                    .setSize(androidx.wear.protolayout.DimensionBuilders.sp(48f))
                                    .build()
                            )
                            .build()
                    )
                    .addContent(
                        androidx.wear.protolayout.LayoutElementBuilders.Text.Builder()
                            .setText(if (weather.hasWeather) weather.temperature else "Syncing...")
                            .setFontStyle(
                                androidx.wear.protolayout.LayoutElementBuilders.FontStyle.Builder()
                                    .setSize(androidx.wear.protolayout.DimensionBuilders.sp(24f))
                                    .setColor(androidx.wear.protolayout.ColorBuilders.argb(primaryColor))
                                    .build()
                            )
                            .build()
                    )
                    .build()
            )
            .build()
    }
}

private data class WeatherTileData(
    val location: String,
    val emoji: String,
    val temperature: String,
    val recommendation: String,
    val weatherCode: Int,
    val isWeatherBackgroundEnabled: Boolean,
) {
    val hasWeather: Boolean
        get() = location.isNotBlank() && temperature.isNotBlank()

    val backgroundColor: Int
        get() = if (!isWeatherBackgroundEnabled) Color.BLACK 
                else weatherBackgroundColor(weatherCode, isNight())

    companion object {
        fun from(context: android.content.Context): WeatherTileData {
            val prefs = HomeWidgetPlugin.getData(context)
            return WeatherTileData(
                location = prefs.getString("text_location", "").orEmpty(),
                emoji = prefs.getString("weatherfit_text_emoji", "☀️").orEmpty(),
                temperature = prefs.getString("text_temperature", "").orEmpty(),
                recommendation = prefs.getString("weatherfit_text_recommendation", "").orEmpty(),
                weatherCode = prefs.getInt("weather_code", -1),
                isWeatherBackgroundEnabled = prefs.getBoolean("weatherfit_is_weather_background_enabled", true)
            )
        }

        fun empty(): WeatherTileData = WeatherTileData(
            location = "",
            emoji = "☀️",
            temperature = "",
            recommendation = "",
            weatherCode = -1,
            isWeatherBackgroundEnabled = true
        )
    }
}

private fun isNight(): Boolean {
    val hour = java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY)
    return hour < 6 || hour >= 21
}

private fun weatherBackgroundColor(code: Int, isNight: Boolean): Int {
    return when {
        code == 0 || code == 800 -> if (isNight) Color.rgb(26, 26, 51) else Color.rgb(255, 153, 0)
        (code in 1..3) || code == 45 || code == 48 || (code in 701..799) || (code in 801..804) -> 
            if (isNight) Color.rgb(38, 38, 51) else Color.rgb(128, 153, 178)
        (code in 51..67) || (code in 80..82) || (code in 95..99) || (code in 200..599) -> 
            if (isNight) Color.rgb(26, 38, 64) else Color.rgb(51, 77, 128)
        (code in 71..77) || (code in 85..86) || (code in 600..699) -> 
            if (isNight) Color.rgb(51, 51, 77) else Color.rgb(102, 128, 179)
        else -> if (isNight) Color.rgb(26, 13, 51) else Color.rgb(98, 0, 238)
    }
}
