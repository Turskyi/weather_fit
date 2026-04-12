import 'dart:async';

import 'package:weather_repository/weather_repository.dart';

abstract interface class WeatherProvider {
  const WeatherProvider();

  Future<WeatherDomain> getCurrentWeather(Location location);

  Future<DailyForecastDomain> getForecast(Location location);
}
