enum WeatherCondition {
  clear,
  rainy,
  cloudy,
  snowy,
  unknown;

  String get toEmoji {
    final DateTime now = DateTime.now();
    final int hour = now.hour;
    // Assume daytime from 6 AM to 6 PM.
    final bool isDaytime = hour >= 6 && hour < 19;
    switch (this) {
      case WeatherCondition.clear:
        // Sun during day, moon at night
        return isDaytime ? '☀️' : '🌕';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.cloudy:
        // Partly cloudy or just cloudy at night.
        return isDaytime ? '🌥️' : '☁️';
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
