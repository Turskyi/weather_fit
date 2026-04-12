import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:weather_repository/weather_repository.dart';

class FallbackWeatherProvider implements WeatherProvider {
  const FallbackWeatherProvider({
    required this.openMeteo,
    required this.openWeatherMap,
    this.forceOpenWeatherMap = false,
  });

  final WeatherProvider openMeteo;
  final WeatherProvider openWeatherMap;
  final bool forceOpenWeatherMap;

  @override
  Future<WeatherDomain> getCurrentWeather(Location location) async {
    if (forceOpenWeatherMap) {
      if (kDebugMode) {
        debugPrint('[Weather] Debug toggle: using OpenWeatherMap');
      }
      return openWeatherMap.getCurrentWeather(location);
    } else {
      try {
        final WeatherDomain result = await openMeteo
            .getCurrentWeather(location)
            .timeout(const Duration(seconds: 4));
        if (kDebugMode) {
          debugPrint('[Weather] Used Open-Meteo');
        }
        return result;
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '[Weather] Open-Meteo failed, '
            'falling back to OpenWeatherMap: $e',
          );
        }
        return openWeatherMap.getCurrentWeather(location);
      }
    }
  }

  @override
  Future<DailyForecastDomain> getForecast(Location location) async {
    if (forceOpenWeatherMap) {
      if (kDebugMode) {
        debugPrint('[Weather] Debug toggle: using OpenWeatherMap (forecast)');
      }
      return openWeatherMap.getForecast(location);
    } else {
      try {
        final DailyForecastDomain result = await openMeteo
            .getForecast(location)
            .timeout(const Duration(seconds: 4));
        if (kDebugMode) {
          debugPrint('[Weather] Used Open-Meteo (forecast)');
        }
        return result;
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '[Weather] Open-Meteo forecast failed, '
            'falling back to OpenWeatherMap: $e',
          );
        }
        return openWeatherMap.getForecast(location);
      }
    }
  }
}
