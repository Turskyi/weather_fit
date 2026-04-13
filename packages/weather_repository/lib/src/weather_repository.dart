import 'dart:async';

import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherRepository {
  WeatherRepository({
    OpenMeteoApiClient? weatherApiClient,
    WeatherProvider? weatherProvider,
  }) : _openMeteoApiClient = weatherApiClient ?? OpenMeteoApiClient(),
       _weatherProvider =
           weatherProvider ??
           OpenMeteoProvider(
             apiClient: weatherApiClient ?? OpenMeteoApiClient(),
           );

  final OpenMeteoApiClient _openMeteoApiClient;
  final WeatherProvider _weatherProvider;

  Future<WeatherDomain> getWeatherByLocation(Location location) async {
    // Use provider (may fallback internally).
    final WeatherDomain weatherDomain = await _weatherProvider
        .getCurrentWeather(location);

    return WeatherDomain(
      temperature: weatherDomain.temperature,
      location: weatherDomain.location,
      condition: weatherDomain.condition,
      countryCode: weatherDomain.countryCode,
      description: weatherDomain.description,
      weatherCode: weatherDomain.weatherCode,
      locale: weatherDomain.locale,
    );
  }

  Future<DailyForecastDomain> getDailyForecast(Location location) async {
    final DailyForecastDomain dailyForecast = await _weatherProvider
        .getForecast(location);
    return dailyForecast;
  }

  Future<WeatherDomain> getClimateProjection({
    required Location location,
    required DateTime date,
  }) async {
    final ClimateChangeProjectionsResponse response = await _openMeteoApiClient
        .getClimateProjection(
          latitude: location.latitude,
          longitude: location.longitude,
          date: date,
        );

    final List<double> maxTemperatures = response.daily.temperature2mMax;
    final List<double> minTemperatures = response.daily.temperature2mMin;
    if (maxTemperatures.isNotEmpty && minTemperatures.isNotEmpty) {
      final double maxTemp = response.daily.temperature2mMax.firstOrNull ?? 0;
      final double minTemp = response.daily.temperature2mMin.firstOrNull ?? 0;
      final double avgTemp = (maxTemp + minTemp) / 2;

      return WeatherDomain(
        temperature: avgTemp,
        maxTemperature: maxTemp,
        minTemperature: minTemp,
        location: location,
        condition: WeatherCondition.unknown,
        countryCode: location.countryCode,
        description: 'Projected',
        // Climate API doesn't provide codes
        weatherCode: -1,
        locale: location.locale,
      );
    } else {
      throw Exception('No max or min temperatures found');
    }
  }

  Future<Location> searchLocation({
    required String query,
    required String locale,
  }) async {
    final LocationResponse response = await _openMeteoApiClient.locationSearch(
      query,
    );

    return Location(
      latitude: response.latitude,
      longitude: response.longitude,
      name: response.name,
      country: response.country,
      province: response.admin1,
      countryCode: response.countryCode,
      locale: locale,
    );
  }
}
