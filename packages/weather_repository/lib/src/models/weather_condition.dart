enum WeatherCondition {
  clear,
  rainy,
  cloudy,
  snowy,
  unknown;

  String get toEmoji {
    switch (this) {
      case WeatherCondition.clear:
        return '☀️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.snowy:
        return '🌨️';
      case WeatherCondition.unknown:
        return '❓';
    }
  }

  bool get isClear => this == WeatherCondition.clear;

  bool get isRainy => this == WeatherCondition.rainy;

  bool get isCloudy => this == WeatherCondition.cloudy;

  bool get isSnowy => this == WeatherCondition.snowy;

  bool get isUnknown => this == WeatherCondition.unknown;
}
