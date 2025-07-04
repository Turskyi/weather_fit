import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:open_meteo_api/src/models/exceptions/location_request_failure.dart';
import 'package:open_meteo_api/src/models/exceptions/weather_not_found_failure.dart';
import 'package:open_meteo_api/src/models/exceptions/weather_request_failure.dart';
import 'package:test/test.dart';

import 'helpers/mocks.dart';

void main() {
  group('OpenMeteoApiClient', () {
    late http.Client httpClient;
    late OpenMeteoApiClient apiClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      apiClient = OpenMeteoApiClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require an httpClient', () {
        expect(OpenMeteoApiClient(), isNotNull);
      });
    });

    group('locationSearch', () {
      const String query = 'mock-query';
      test('makes correct http request', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await apiClient.locationSearch(query);
        } catch (_) {}
        verify(
          () => httpClient.get(
            Uri.https(
              'geocoding-api.open-meteo.com',
              '/v1/search',
              <String, String>{'name': query, 'count': '1'},
            ),
          ),
        ).called(1);
      });

      test('throws LocationRequestFailure on non-200 response', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => apiClient.locationSearch(query),
          throwsA(isA<LocationRequestFailure>()),
        );
      });

      test('throws LocationNotFoundFailure on error response', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        await expectLater(
          apiClient.locationSearch(query),
          throwsA(isA<LocationNotFoundFailure>()),
        );
      });

      test('throws LocationNotFoundFailure on empty response', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{"results": []}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        await expectLater(
          apiClient.locationSearch(query),
          throwsA(isA<LocationNotFoundFailure>()),
        );
      });

      test('returns Location on valid response', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn(
          '''
{
  "results": [
    {
      "id": 4887398,
      "name": "Chicago",
      "latitude": 41.85003,
      "longitude": -87.65005,
      "country_code": "US",
      "country": "United States",
      "admin1": "Illinois"
    }
  ]
}''',
        );
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final LocationResponse actual = await apiClient.locationSearch(query);
        expect(
          actual,
          isA<LocationResponse>()
              .having((LocationResponse l) => l.name, 'name', 'Chicago')
              .having((LocationResponse l) => l.id, 'id', 4887398)
              .having((LocationResponse l) => l.latitude, 'latitude', 41.85003)
              .having(
                (LocationResponse l) => l.longitude,
                'longitude',
                -87.65005,
              ),
        );
      });
    });

    group('getWeather', () {
      const double latitude = 41.85003;
      const double longitude = -87.6500;

      test('makes correct http request', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await apiClient.getWeather(latitude: latitude, longitude: longitude);
        } catch (_) {}
        verify(
          () => httpClient.get(
            Uri.https('api.open-meteo.com', 'v1/forecast', <String, dynamic>{
              'latitude': '$latitude',
              'longitude': '$longitude',
              'current_weather': 'true',
            }),
          ),
        ).called(1);
      });

      test('throws WeatherRequestFailure on non-200 response', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => apiClient.getWeather(
            latitude: latitude,
            longitude: longitude,
          ),
          throwsA(isA<WeatherRequestFailure>()),
        );
      });

      test('throws WeatherNotFoundFailure on empty response', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => apiClient.getWeather(
            latitude: latitude,
            longitude: longitude,
          ),
          throwsA(isA<WeatherNotFoundFailure>()),
        );
      });

      test('returns weather on valid response', () async {
        final MockResponse response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn(
          '''
{
"latitude": 43,
"longitude": -87.875,
"generationtime_ms": 0.2510547637939453,
"utc_offset_seconds": 0,
"timezone": "GMT",
"timezone_abbreviation": "GMT",
"elevation": 189,
"current_weather": {
"temperature": 15.3,
"windspeed": 25.8,
"winddirection": 310,
"weathercode": 63,
"time": "2022-09-12T01:00"
}
}
        ''',
        );
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final WeatherResponse actual = await apiClient.getWeather(
          latitude: latitude,
          longitude: longitude,
        );
        expect(
          actual,
          isA<WeatherResponse>()
              .having((WeatherResponse w) => w.temperature, 'temperature', 15.3)
              .having(
                (WeatherResponse w) => w.weatherCode,
                'weatherCode',
                63.0,
              ),
        );
      });
    });
  });
}
