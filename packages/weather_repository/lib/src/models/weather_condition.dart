enum WeatherCondition {
  clear,
  rainy,
  cloudy,
  snowy,
  unknown;

  static const int defaultDayStartHour = 6;
  static const int defaultNightStartHour = 22;

  static const int minDayStartHour = 4;
  static const int maxDayStartHour = 10;
  static const int minNightStartHour = 18;
  static const int maxNightStartHour = 23;

  static int _dayStartHour = defaultDayStartHour;
  static int _nightStartHour = defaultNightStartHour;

  static int get dayStartHour => _dayStartHour;

  static int get nightStartHour => _nightStartHour;

  static bool areDayNightHoursValid({
    required int dayStartHour,
    required int nightStartHour,
  }) {
    final bool dayStartInRange =
        dayStartHour >= minDayStartHour && dayStartHour <= maxDayStartHour;
    final bool nightStartInRange =
        nightStartHour >= minNightStartHour &&
        nightStartHour <= maxNightStartHour;

    return dayStartInRange &&
        nightStartInRange &&
        dayStartHour < nightStartHour;
  }

  static void configureDayNightHours({
    required int dayStartHour,
    required int nightStartHour,
  }) {
    final bool isValid = areDayNightHoursValid(
      dayStartHour: dayStartHour,
      nightStartHour: nightStartHour,
    );

    if (isValid) {
      _dayStartHour = dayStartHour;
      _nightStartHour = nightStartHour;
    } else {
      _dayStartHour = defaultDayStartHour;
      _nightStartHour = defaultNightStartHour;
    }
  }

  String get toEmoji {
    final DateTime now = DateTime.now();
    final int hour = now.hour;
    final bool isDaytime = hour >= _dayStartHour && hour < _nightStartHour;
    switch (this) {
      case WeatherCondition.clear:
        // Sun during day, moon at night.
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

  bool get isPrecipitation {
    return this == WeatherCondition.rainy || this == WeatherCondition.snowy;
  }
}
