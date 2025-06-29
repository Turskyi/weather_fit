import 'dart:async';

import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherRepository {
  WeatherRepository({
    OpenMeteoApiClient? weatherApiClient,
  }) : _openMeteoApiClient = weatherApiClient ?? OpenMeteoApiClient();

  final OpenMeteoApiClient _openMeteoApiClient;

  Future<WeatherDomain> getWeatherByLocation(Location location) async {
    final double latitude = location.latitude;
    final double longitude = location.longitude;

    final WeatherResponse weatherResponse =
        await _openMeteoApiClient.getWeather(
      latitude: latitude,
      longitude: longitude,
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
}

extension on int {
  WeatherCondition get toCondition {
    switch (this) {
      case 0:
        return WeatherCondition.clear;
      case 1:
      case 2:
      case 3:
      case 45:
      case 48:
        return WeatherCondition.cloudy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
      case 95:
      case 96:
      case 99:
        return WeatherCondition.rainy;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return WeatherCondition.snowy;
      default:
        return WeatherCondition.unknown;
    }
  }
}
