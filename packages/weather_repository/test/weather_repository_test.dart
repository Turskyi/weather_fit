import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart' as open_meteo_api;
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

import 'helpers/mocks.dart';

void main() {
  group('WeatherRepository', () {
    late open_meteo_api.OpenMeteoApiClient weatherApiClient;
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherApiClient = MockOpenMeteoApiClient();
      weatherRepository = WeatherRepository(weatherApiClient: weatherApiClient);
    });

    group('constructor', () {
      test('instantiates internal weather api client when not injected', () {
        expect(WeatherRepository(), isNotNull);
      });
    });

    group('getWeatherByLocation', () {
      const double latitude = 41.85003;
      const double longitude = -87.65005;

      test('calls getWeather with correct latitude/longitude', () async {
        final MockWeather weather = MockWeather();
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.code).thenReturn(0);
        when(() => weather.description).thenReturn('clear');

        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((Invocation _) async => weather);

        final WeatherDomain actual = await weatherRepository
            .getWeatherByLocation(
              Location(latitude: latitude, longitude: longitude, locale: 'en'),
            );

        expect(
          actual,
          isA<WeatherDomain>()
              .having((WeatherDomain w) => w.temperature, 'temperature', 42.42)
              .having(
                (WeatherDomain w) => w.condition,
                'condition',
                WeatherCondition.clear,
              ),
        );

        verify(
          () => weatherApiClient.getWeather(
            latitude: latitude,
            longitude: longitude,
          ),
        ).called(1);
      });

      test('throws when getWeather fails', () async {
        final Exception exception = Exception('oops');
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenThrow(exception);

        expect(
          () async => weatherRepository.getWeatherByLocation(
            Location(latitude: latitude, longitude: longitude, locale: 'en'),
          ),
          throwsA(exception),
        );
      });
    });

    group('getDailyForecast', () {
      const double latitude = 41.85003;
      const double longitude = -87.65005;

      test('calls getDailyForecast with correct latitude/longitude', () async {
        final open_meteo_api.DailyForecastResponse forecast =
            open_meteo_api.DailyForecastResponse(
              hourly: open_meteo_api.Hourly(
                time: <String>['2023-01-01T00:00'],
                temperature2m: <double>[10.0],
                weathercode: <int>[0],
              ),
            );

        when(
          () => weatherApiClient.getDailyForecast(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async => forecast);

        final DailyForecastDomain actual = await weatherRepository
            .getDailyForecast(
              Location(latitude: latitude, longitude: longitude, locale: 'en'),
            );

        expect(actual.forecast.length, 1);
        expect(actual.forecast.first.temperature, 10.0);

        verify(
          () => weatherApiClient.getDailyForecast(
            latitude: latitude,
            longitude: longitude,
          ),
        ).called(1);
      });
    });

    group('searchLocation', () {
      test('calls locationSearch with correct query', () async {
        const String city = 'chicago';
        final MockLocation locationResponse = MockLocation();
        when(() => locationResponse.latitude).thenReturn(41.85003);
        when(() => locationResponse.longitude).thenReturn(-87.65005);
        when(() => locationResponse.name).thenReturn('Chicago');
        when(() => locationResponse.country).thenReturn('United States');
        when(() => locationResponse.admin1).thenReturn('Illinois');
        when(() => locationResponse.countryCode).thenReturn('US');

        when(
          () => weatherApiClient.locationSearch(any()),
        ).thenAnswer((_) async => locationResponse);

        final Location actual = await weatherRepository.searchLocation(
          query: city,
          locale: 'en',
        );

        expect(actual.name, 'Chicago');
        verify(() => weatherApiClient.locationSearch(city)).called(1);
      });
    });
  });
}
