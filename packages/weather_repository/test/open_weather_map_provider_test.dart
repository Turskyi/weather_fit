import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('OpenWeatherMapProvider', () {
    late http.Client httpClient;
    late OpenWeatherMapProvider provider;
    const String apiKey = 'test_api_key';
    final Location location = Location(latitude: 0, longitude: 0, locale: 'en');

    setUp(() {
      httpClient = MockHttpClient();
      provider = OpenWeatherMapProvider(apiKey: apiKey, httpClient: httpClient);
      registerFallbackValue(Uri());
    });

    group('getCurrentWeather', () {
      test(
        'maps OpenWeatherMap codes to WMO codes and correct conditions',
        () async {
          final Map<int, List<Object>> mapping = <int, List<Object>>{
            200: <Object>[95, WeatherCondition.rainy],
            // Thunderstorm
            300: <Object>[51, WeatherCondition.rainy],
            // Drizzle
            500: <Object>[61, WeatherCondition.rainy],
            // Rain
            511: <Object>[66, WeatherCondition.rainy],
            // Freezing rain
            520: <Object>[80, WeatherCondition.rainy],
            // Rain showers
            600: <Object>[71, WeatherCondition.snowy],
            // Snow
            611: <Object>[77, WeatherCondition.snowy],
            // Sleet
            620: <Object>[85, WeatherCondition.snowy],
            // Snow showers
            701: <Object>[45, WeatherCondition.cloudy],
            // Fog
            800: <Object>[0, WeatherCondition.clear],
            // Clear
            801: <Object>[1, WeatherCondition.cloudy],
            // Mainly clear
            802: <Object>[2, WeatherCondition.cloudy],
            // Partly cloudy
            803: <Object>[2, WeatherCondition.cloudy],
            // Broken clouds -> Partly cloudy
            804: <Object>[3, WeatherCondition.cloudy],
            // Overcast
            999: <Object>[999, WeatherCondition.unknown],
            // Unknown
          };

          for (final MapEntry<int, List<Object>> entry in mapping.entries) {
            final int owmCode = entry.key;
            final int expectedWmoCode = entry.value[0] as int;
            final WeatherCondition expectedCondition =
                entry.value[1] as WeatherCondition;

            final String responseBody = jsonEncode(<String, dynamic>{
              'main': <String, dynamic>{'temp': 20.0},
              'weather': <Map<String, dynamic>>[
                <String, dynamic>{'id': owmCode, 'description': 'desc'},
              ],
            });

            when(
              () => httpClient.get(any()),
            ).thenAnswer((_) async => http.Response(responseBody, 200));

            final WeatherDomain weather = await provider.getCurrentWeather(
              location,
            );
            expect(
              weather.weatherCode,
              expectedWmoCode,
              reason:
                  'OWM code $owmCode should map to WMO code $expectedWmoCode',
            );
            expect(
              weather.condition,
              expectedCondition,
              reason:
                  'OWM code $owmCode should result in condition '
                  '$expectedCondition',
            );
          }
        },
      );
    });

    group('getForecast', () {
      test(
        'maps OpenWeatherMap codes to WMO codes correctly in forecast',
        () async {
          final String responseBody = jsonEncode(<String, dynamic>{
            'list': <Map<String, dynamic>>[
              <String, dynamic>{
                'dt_txt': '2023-01-01 12:00:00',
                'main': <String, dynamic>{'temp': 15.0},
                'weather': <Map<String, dynamic>>[
                  <String, dynamic>{'id': 800}, // Clear -> 0
                ],
              },
              <String, dynamic>{
                'dt_txt': '2023-01-01 15:00:00',
                'main': <String, dynamic>{'temp': 12.0},
                'weather': <Map<String, dynamic>>[
                  <String, dynamic>{'id': 500}, // Rain -> 61
                ],
              },
            ],
          });

          when(
            () => httpClient.get(any()),
          ).thenAnswer((_) async => http.Response(responseBody, 200));

          final DailyForecastDomain forecast = await provider.getForecast(
            location,
          );
          expect(forecast.forecast.length, 2);
          expect(forecast.forecast[0].weatherCode, 0);
          expect(forecast.forecast[1].weatherCode, 61);
        },
      );
    });
  });
}
