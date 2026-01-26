import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart';

import 'constants/dummy_constants.dart' as dummy_constants;

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late LocalDataSource localDataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    localDataSource = localDataSource = LocalDataSource(mockSharedPreferences);
  });

  group('getOutfitImageAssetPath', () {
    test('should round temperature down to nearest 10 degrees and clamp to '
        '[-30, 30]', () {
      final List<Map<String, Object?>> testCases = <Map<String, Object?>>[
        <String, Object?>{'temp': 25.0, 'expected': 30},
        <String, Object?>{'temp': 15.0, 'expected': 20},
        <String, Object?>{'temp': 5.0, 'expected': 10},
        <String, Object?>{'temp': -5.0, 'expected': -10},
        <String, Object?>{'temp': -15.0, 'expected': -20},
        <String, Object?>{'temp': 35.0, 'expected': 30},
        <String, Object?>{'temp': -35.0, 'expected': -30},
        <String, Object?>{'temp': 45.0, 'expected': 30},
        <String, Object?>{'temp': 0, 'expected': 0},
        <String, Object?>{'temp': 0.0, 'expected': 0},
        <String, Object?>{'temp': -1.0, 'expected': 0},
      ];

      for (final Map<String, dynamic> testCase in testCases) {
        final Object? tempVal = testCase['temp'];
        final Object? expectedVal = testCase['expected'];

        if (tempVal is num && expectedVal is int) {
          final double temp = tempVal.toDouble();
          final int expectedRounded = expectedVal;

          final Weather weather = Weather(
            condition: WeatherCondition.clear,
            location: dummy_constants.dummyLocation,
            temperature: Temperature(value: temp),
            temperatureUnits: TemperatureUnits.celsius,
            countryCode: dummy_constants.dummyCountryCode,
            description: dummy_constants.dummyWeatherDescription,
            code: dummy_constants.dummyWeatherCode,
            locale: dummy_constants.dummyLocale,
          );

          final String path = localDataSource.getOutfitImageAssetPath(weather);
          expect(
            path,
            contains('clear_$expectedRounded.png'),
            reason: 'Failed for temperature $temp',
          );
        }
      }
    });

    test('should return -40 asset if temperature is below -40 Celsius', () {
      final Weather weather = const Weather(
        condition: WeatherCondition.clear,
        location: dummy_constants.dummyLocation,
        temperature: Temperature(value: -45),
        temperatureUnits: TemperatureUnits.celsius,
        countryCode: dummy_constants.dummyCountryCode,
        description: dummy_constants.dummyWeatherDescription,
        code: dummy_constants.dummyWeatherCode,
        locale: dummy_constants.dummyLocale,
      );

      final String path = localDataSource.getOutfitImageAssetPath(weather);
      expect(path, contains('-40.png'));
    });

    test('should convert Fahrenheit to Celsius before rounding', () {
      // 77°F is 25°C. 25°C should round down to 20.
      final Weather weather = const Weather(
        condition: WeatherCondition.clear,
        location: dummy_constants.dummyLocation,
        temperature: Temperature(value: 77),
        temperatureUnits: TemperatureUnits.fahrenheit,
        countryCode: dummy_constants.dummyCountryCode,
        description: dummy_constants.dummyWeatherDescription,
        code: dummy_constants.dummyWeatherCode,
        locale: dummy_constants.dummyLocale,
      );

      final String path = localDataSource.getOutfitImageAssetPath(weather);
      expect(path, contains('clear_30.png'));
    });

    test('should return "precipitation_0.png" when condition is rainy and '
        'temperature is -1', () {
      final Weather weather = const Weather(
        condition: WeatherCondition.rainy,
        location: dummy_constants.dummyLocation,
        temperature: Temperature(value: -1.0),
        temperatureUnits: TemperatureUnits.celsius,
        countryCode: dummy_constants.dummyCountryCode,
        description: dummy_constants.dummyWeatherDescription,
        code: dummy_constants.dummyWeatherCode,
        locale: dummy_constants.dummyLocale,
      );

      final String path = localDataSource.getOutfitImageAssetPath(weather);
      expect(path, contains('precipitation_0.png'));
    });
  });

  group('LocalDataSource - Temperature Rounding Logic', () {
    test('should return 0 when temperature is 0.0', () {
      // Arrange
      const Temperature temperature = Temperature(value: 0.0);
      const Weather weather = Weather(
        condition: WeatherCondition.clear,
        temperature: temperature,
        temperatureUnits: TemperatureUnits.celsius,
        location: dummy_constants.dummyLocation,
        countryCode: dummy_constants.dummyCountryCode,
        description: dummy_constants.dummyWeatherDescription,
        code: dummy_constants.dummyWeatherCode,
        locale: dummy_constants.dummyLocale,
      );

      // Act
      final String assetPath = localDataSource.getOutfitImageAssetPath(weather);

      // Assert
      // The formula: (0.0 / 10).floor() * 10 = 0
      // Expected path segment: clear_0.png
      expect(assetPath, contains('clear_0.png'));
    });

    test('should round down correctly for positive and negative values', () {
      final Map<double, int> testCases = <double, int>{
        10.0: 10,
        19.9: 20,
        -5.0: -10,
        -10.1: -10,
      };

      for (final MapEntry<double, int> entry in testCases.entries) {
        final Weather weather = Weather(
          condition: WeatherCondition.clear,
          temperature: Temperature(value: entry.key),
          temperatureUnits: TemperatureUnits.celsius,
          location: dummy_constants.dummyLocation,
          countryCode: dummy_constants.dummyCountryCode,
          description: dummy_constants.dummyWeatherDescription,
          code: dummy_constants.dummyWeatherCode,
          locale: dummy_constants.dummyLocale,
        );

        final String assetPath = localDataSource.getOutfitImageAssetPath(
          weather,
        );

        // Note: The code clamps results to -30...30
        int expectedRounded = entry.value;
        if (expectedRounded > 30) expectedRounded = 30;
        if (expectedRounded < -30) expectedRounded = -30;

        expect(
          assetPath,
          contains('clear_$expectedRounded.png'),
          reason: 'Failed for temperature ${entry.key}',
        );
      }
    });
  });

  group('LocalDataSource - getOutfitImageAssetPath Rounding Logic', () {
    test('should return 0 for -1.0 degrees after fix (nearest decade)', () {
      // Arrange
      const Weather weather = Weather(
        condition: WeatherCondition.clear,
        temperature: Temperature(value: -1.0),
        temperatureUnits: TemperatureUnits.celsius,
        location: dummy_constants.dummyLocation,
        countryCode: dummy_constants.dummyCountryCode,
        description: dummy_constants.dummyWeatherDescription,
        code: dummy_constants.dummyWeatherCode,
        locale: dummy_constants.dummyLocale,
      );

      // Act
      final String assetPath = localDataSource.getOutfitImageAssetPath(weather);

      // Assert: (-1.0 / 10).round() = 0. 0 * 10 = 0.
      expect(assetPath, contains('clear_0.png'));
    });

    test('should round to the nearest decade correctly', () {
      final Map<double, int> testCases = <double, int>{
        -14.9: -10, // Closer to -10
        -15.0: -20, // Midpoint rounds to -20
        -4.0: 0, // Closer to 0
        4.0: 0, // Closer to 0
        5.0: 10, // Midpoint rounds up
        26.0: 30, // Closer to 30
      };

      for (final MapEntry<double, int> entry in testCases.entries) {
        final Weather weather = Weather(
          condition: WeatherCondition.clear,
          temperature: Temperature(value: entry.key),
          temperatureUnits: TemperatureUnits.celsius,
          location: dummy_constants.dummyLocation,
          countryCode: dummy_constants.dummyCountryCode,
          description: dummy_constants.dummyWeatherDescription,
          code: dummy_constants.dummyWeatherCode,
          locale: dummy_constants.dummyLocale,
        );

        final String assetPath = localDataSource.getOutfitImageAssetPath(
          weather,
        );

        expect(
          assetPath,
          contains('clear_${entry.value}.png'),
          reason:
              'Failed for temperature ${entry.key}: expected ${entry.value}',
        );
      }
    });
  });
}
