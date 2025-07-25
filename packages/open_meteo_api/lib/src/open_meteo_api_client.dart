import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:open_meteo_api/src/models/exceptions/location_request_failure.dart';
import 'package:open_meteo_api/src/models/exceptions/location_response_failure.dart';
import 'package:open_meteo_api/src/models/exceptions/weather_not_found_failure.dart';
import 'package:open_meteo_api/src/models/exceptions/weather_request_failure.dart';

import 'models/exceptions/weather_response_failure.dart';

/// {@template open_meteo_api_client}
/// Dart API Client which wraps the [Open Meteo API](https://open-meteo.com).
/// {@endtemplate}
class OpenMeteoApiClient {
  /// {@macro open_meteo_api_client}
  OpenMeteoApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const String _baseUrlWeather = 'api.open-meteo.com';
  static const String _baseUrlGeocoding = 'geocoding-api.open-meteo.com';

  final http.Client _httpClient;

  /// Finds a [LocationResponse] `/v1/search/?name=(query)`.
  Future<LocationResponse> locationSearch(String query) async {
    final Uri locationRequest = Uri.https(
      _baseUrlGeocoding,
      '/v1/search',
      <String, String>{'name': query, 'count': '1'},
    );

    final http.Response locationResponse = await _httpClient.get(
      locationRequest,
    );

    if (locationResponse.statusCode != HttpStatus.ok) {
      throw LocationRequestFailure();
    }

    final Object locationData = jsonDecode(locationResponse.body);
    if (locationData is Map<String, Object?>) {
      final Map<String, Object?> locationJson = locationData;
      if (!locationJson.containsKey('results')) throw LocationNotFoundFailure();
      final Object? locationResults = locationJson['results'];
      if (locationResults is List<Object?>) {
        final List<Object?> results = locationResults;
        if (results.isEmpty) throw LocationNotFoundFailure();
        final Object? location = results.firstOrNull;
        if (location is Map<String, Object?>) {
          return LocationResponse.fromJson(location);
        }
      }
    }
    throw LocationResponseFailure();
  }

  /// Fetches [WeatherResponse] for a given [latitude] and [longitude].
  Future<WeatherResponse> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final Uri weatherRequest = Uri.https(
      _baseUrlWeather,
      'v1/forecast',
      <String, String>{
        'latitude': '$latitude',
        'longitude': '$longitude',
        'current_weather': 'true',
      },
    );

    final http.Response weatherResponse = await _httpClient.get(weatherRequest);

    if (weatherResponse.statusCode != HttpStatus.ok) {
      throw WeatherRequestFailure();
    }

    final Object weatherData = jsonDecode(weatherResponse.body);
    if (weatherData is Map<String, Object?>) {
      final Map<String, Object?> weatherJson = weatherData;
      if (!weatherJson.containsKey('current_weather')) {
        throw WeatherNotFoundFailure();
      }
      final Object? currentWeather = weatherJson['current_weather'];
      if (currentWeather is Map<String, Object?>) {
        return WeatherResponse.fromJson(currentWeather);
      }
    }

    throw WeatherResponseFailure();
  }
}
