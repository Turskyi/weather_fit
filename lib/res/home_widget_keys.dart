enum HomeWidgetKey {
  textEmoji,
  textLocation,
  textTemperature,
  textLastUpdated,
  textRecommendation,
  forecastData,
  imageWeather,
  weatherCode,
  isWeatherBackgroundEnabled,
  locationLatitude,
  locationLongitude,
  temperatureUnit,
  widgetUpdateFrequency,
  selectedLanguage;

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
      case HomeWidgetKey.isWeatherBackgroundEnabled:
        return 'weatherfit_is_weather_background_enabled';
      case HomeWidgetKey.textLastUpdated:
        return 'weatherfit_text_last_updated';
      case HomeWidgetKey.textRecommendation:
        return 'weatherfit_text_recommendation';
      case HomeWidgetKey.textEmoji:
        return 'weatherfit_text_emoji';
      case HomeWidgetKey.locationLatitude:
        return 'weatherfit_location_latitude';
      case HomeWidgetKey.locationLongitude:
        return 'weatherfit_location_longitude';
      case HomeWidgetKey.temperatureUnit:
        return 'weatherfit_temperature_unit';
      case HomeWidgetKey.widgetUpdateFrequency:
        return 'weatherfit_widget_update_frequency';
      case HomeWidgetKey.selectedLanguage:
        return 'selected_language';
    }
  }
}
