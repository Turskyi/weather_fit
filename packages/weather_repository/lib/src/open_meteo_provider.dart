import 'dart:async';

import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:weather_repository/src/utils/weather_code_to_condition.dart';
import 'package:weather_repository/weather_repository.dart';

class OpenMeteoProvider implements WeatherProvider {
  OpenMeteoProvider({OpenMeteoApiClient? apiClient})
    : _apiClient = apiClient ?? OpenMeteoApiClient();

  final OpenMeteoApiClient _apiClient;

  @override
  Future<WeatherDomain> getCurrentWeather(Location location) async {
    final WeatherResponse weatherResponse = await _apiClient.getWeather(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    return WeatherDomain(
      temperature: weatherResponse.temperature,
      location: location,
      condition: weatherResponse.code.toCondition,
      countryCode: location.countryCode,
      description: weatherResponse.description,
      weatherCode: weatherResponse.code,
      locale: location.locale,
    );
  }

  @override
  Future<DailyForecastDomain> getForecast(Location location) async {
    final DailyForecastResponse dailyForecastResponse = await _apiClient
        .getDailyForecast(
          latitude: location.latitude,
          longitude: location.longitude,
        );
    final List<ForecastItemDomain> forecastItems = <ForecastItemDomain>[];
    for (int i = 0; i < dailyForecastResponse.hourly.time.length; i++) {
      forecastItems.add(
        ForecastItemDomain(
          time: dailyForecastResponse.hourly.time[i],
          temperature: dailyForecastResponse.hourly.temperature2m[i],
          weatherCode: dailyForecastResponse.hourly.weathercode[i],
        ),
      );
    }
    return DailyForecastDomain(forecast: forecastItems);
  }
}
