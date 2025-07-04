import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'models/exceptions/nominatim_location_request_failure.dart';
import 'models/responses/nominatim_location_response.dart';

/// {@template nominatim_api_client}
/// Dart API Client for Nominatim (OpenStreetMap).
/// {@endtemplate}
class NominatimApiClient {
  /// {@macro nominatim_api_client}
  NominatimApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const String _baseUrl = 'nominatim.openstreetmap.org';

  final http.Client _httpClient;

  /// Finds a [NominatimLocationResponse] using `/search?q=(query)`.
  Future<NominatimLocationResponse> locationSearch(String query) async {
    final Uri requestUri = Uri.https(
      _baseUrl,
      '/search',
      <String, String>{
        'q': query,
        'format': 'json',
        'limit': '1',
        'accept-language': 'uk,en',
      },
    );

    final http.Response response = await _httpClient.get(
      requestUri,
      headers: <String, String>{
        'User-Agent': 'WeatherFitApp/1.0 (contact: support@weather-fit.com)',
      },
    );

    if (response.statusCode != HttpStatus.ok) {
      throw NominatimLocationRequestFailure();
    }

    final List<dynamic> body = jsonDecode(response.body);
    if (body.isEmpty || body.first is! Map<String, dynamic>) {
      throw NominatimLocationRequestFailure();
    }

    return NominatimLocationResponse.fromJson(
      body.first as Map<String, dynamic>,
    );
  }
}
