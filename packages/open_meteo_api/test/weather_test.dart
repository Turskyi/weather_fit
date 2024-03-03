import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/test.dart';

void main() {
  group('Weather', () {
    group('fromJson', () {
      test('returns correct Weather object', () {
        expect(
          WeatherResponse.fromJson(
            <String, dynamic>{'temperature': 15.3, 'weathercode': 63},
          ),
          isA<WeatherResponse>()
              .having((WeatherResponse w) => w.temperature, 'temperature', 15.3)
              .having((WeatherResponse w) => w.weatherCode, 'weatherCode', 63),
        );
      });
    });
  });
}
