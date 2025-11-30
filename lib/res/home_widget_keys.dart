enum HomeWidgetKey {
  textEmoji,
  textLocation,
  textTemperature,
  textLastUpdated,
  textRecommendation,
  forecastData,
  imageWeather;

  String get stringValue {
    switch (this) {
      case HomeWidgetKey.textEmoji:
        return 'text_emoji';
      case HomeWidgetKey.textLocation:
        return 'text_location';
      case HomeWidgetKey.textTemperature:
        return 'text_temperature';
      case HomeWidgetKey.textLastUpdated:
        return 'text_last_updated';
      case HomeWidgetKey.textRecommendation:
        return 'text_recommendation';
      case HomeWidgetKey.imageWeather:
        return 'image_weather';
      case HomeWidgetKey.forecastData:
        return 'forecast_data';
    }
  }
}
