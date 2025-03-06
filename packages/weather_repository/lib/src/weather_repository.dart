import 'dart:async';

import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherRepository {
  WeatherRepository({OpenMeteoApiClient? weatherApiClient})
      : _weatherApiClient = weatherApiClient ?? OpenMeteoApiClient();

  final OpenMeteoApiClient _weatherApiClient;

  Future<WeatherDomain> getWeather(String city) async {
    final LocationResponse location = await _weatherApiClient.locationSearch(
      city,
    );
    final WeatherResponse weather = await _weatherApiClient.getWeather(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    return WeatherDomain(
      temperature: weather.temperature,
      location: location.name,
      condition: weather.weatherCode.toInt().toCondition,
      countryCode: location.countryCode,
    );
  }

  Future<Location> getLocation(String query) async {
    final LocationResponse response = await _weatherApiClient.locationSearch(
      query,
    );

    return Location(
      id: response.id,
      name: response.name,
      latitude: response.latitude,
      longitude: response.longitude,
      countryCode: response.countryCode,
      country: response.country,
      province: response.admin1,
    );
  }

  Future<WeatherDomain> getWeatherByLocation(Location location) async {
    final double latitude = location.latitude;
    final double longitude = location.longitude;

    final WeatherResponse weather = await _weatherApiClient.getWeather(
      latitude: latitude,
      longitude: longitude,
    );

    final String locationName = location.name.isEmpty
        ? 'Lat: ${latitude.toStringAsFixed(2)}, '
            'Lon: ${longitude.toStringAsFixed(2)}'
        : location.name;

    return WeatherDomain(
      temperature: weather.temperature,
      location: locationName,
      condition: weather.weatherCode.toInt().toCondition,
      countryCode: location.countryCode,
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
