enum HomeWidgetKey {
  textEmoji,
  textLocation,
  textTemperature,
  textLastUpdated,
  textRecommendation,
  forecastData,
  imageWeather,
  weatherCode;

  String get stringValue {
    switch (this) {
      case HomeWidgetKey.textLocation:
        return 'text_location';
      case HomeWidgetKey.textTemperature:
        return 'text_temperature';
      case HomeWidgetKey.imageWeather:
        return 'image_weather';
      case HomeWidgetKey.forecastData:
        return 'forecast_data';
      case HomeWidgetKey.weatherCode:
        return 'weather_code';
      case HomeWidgetKey.textLastUpdated:
        return 'weatherfit_text_last_updated';
      case HomeWidgetKey.textRecommendation:
        return 'weatherfit_text_recommendation';
      case HomeWidgetKey.textEmoji:
        return 'weatherfit_text_emoji';
    }
  }
}
