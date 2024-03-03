import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:open_meteo_api/open_meteo_api.dart';

/// Exception thrown when locationSearch fails.
class LocationRequestFailure implements Exception {}

/// Exception thrown when the provided location is not found.
class LocationNotFoundFailure implements Exception {}

/// Exception thrown when getWeather fails.
class WeatherRequestFailure implements Exception {}

/// Exception thrown when weather for provided location is not found.
class WeatherNotFoundFailure implements Exception {}

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

    final http.Response locationResponse =
        await _httpClient.get(locationRequest);

    if (locationResponse.statusCode != 200) {
      throw LocationRequestFailure();
    }

    final Map<String, dynamic> locationJson =
        jsonDecode(locationResponse.body) as Map<String, dynamic>;

    if (!locationJson.containsKey('results')) throw LocationNotFoundFailure();

    final List<dynamic> results = locationJson['results'] as List<dynamic>;

    if (results.isEmpty) throw LocationNotFoundFailure();

    return LocationResponse.fromJson(results.first as Map<String, dynamic>);
  }

  /// Fetches [WeatherResponse] for a given [latitude] and [longitude].
  Future<WeatherResponse> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final Uri weatherRequest =
        Uri.https(_baseUrlWeather, 'v1/forecast', <String, String>{
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current_weather': 'true',
    });

    final http.Response weatherResponse = await _httpClient.get(weatherRequest);

    if (weatherResponse.statusCode != 200) {
      throw WeatherRequestFailure();
    }

    final Map<String, dynamic> bodyJson =
        jsonDecode(weatherResponse.body) as Map<String, dynamic>;

    if (!bodyJson.containsKey('current_weather')) {
      throw WeatherNotFoundFailure();
    }

    final Map<String, dynamic> weatherJson =
        bodyJson['current_weather'] as Map<String, dynamic>;

    return WeatherResponse.fromJson(weatherJson);
  }
}
