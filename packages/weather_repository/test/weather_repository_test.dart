import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart' as open_meteo_api;
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

class MockOpenMeteoApiClient extends Mock
    implements open_meteo_api.OpenMeteoApiClient {}

class MockLocation extends Mock implements open_meteo_api.LocationResponse {}

class MockWeather extends Mock implements open_meteo_api.WeatherResponse {}

const String countryCode = 'us';

void main() {
  group('WeatherRepository', () {
    late open_meteo_api.OpenMeteoApiClient weatherApiClient;
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherApiClient = MockOpenMeteoApiClient();
      weatherRepository = WeatherRepository(
        weatherApiClient: weatherApiClient,
      );
    });

    group('constructor', () {
      test('instantiates internal weather api client when not injected', () {
        expect(WeatherRepository(), isNotNull);
      });
    });

    group('getWeather', () {
      const String city = 'chicago';
      const double latitude = 41.85003;
      const double longitude = -87.65005;

      test('calls locationSearch with correct city', () async {
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(() => weatherApiClient.locationSearch(city)).called(1);
      });

      test('throws when locationSearch fails', () async {
        final Exception exception = Exception('oops');
        when(() => weatherApiClient.locationSearch(any())).thenThrow(exception);
        expect(
          () async => weatherRepository.getWeather(city),
          throwsA(exception),
        );
      });

      test('calls getWeather with correct latitude/longitude', () async {
        final MockLocation location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(
          () => weatherApiClient.getWeather(
            latitude: latitude,
            longitude: longitude,
          ),
        ).called(1);
      });

      test('throws when getWeather fails', () async {
        final Exception exception = Exception('oops');
        final MockLocation location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenThrow(exception);
        expect(
          () async => weatherRepository.getWeather(city),
          throwsA(exception),
        );
      });

      test('returns correct weather on success (clear)', () async {
        final MockLocation location = MockLocation();
        final MockWeather weather = MockWeather();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(0);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async => weather);
        final WeatherDomain actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          const WeatherDomain(
            temperature: 42.42,
            location: city,
            condition: WeatherCondition.clear,
            countryCode: countryCode,
          ),
        );
      });

      test('returns correct weather on success (cloudy)', () async {
        final MockLocation location = MockLocation();
        final MockWeather weather = MockWeather();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(1);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async => weather);
        final WeatherDomain actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          const WeatherDomain(
            temperature: 42.42,
            location: city,
            condition: WeatherCondition.cloudy,
            countryCode: countryCode,
          ),
        );
      });

      test('returns correct weather on success (rainy)', () async {
        final MockLocation location = MockLocation();
        final MockWeather weather = MockWeather();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(51);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async => weather);
        final WeatherDomain actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          const WeatherDomain(
            temperature: 42.42,
            location: city,
            condition: WeatherCondition.rainy,
            countryCode: countryCode,
          ),
        );
      });

      test('returns correct weather on success (snowy)', () async {
        final MockLocation location = MockLocation();
        final MockWeather weather = MockWeather();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(71);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async => weather);
        final WeatherDomain actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          const WeatherDomain(
            temperature: 42.42,
            location: city,
            condition: WeatherCondition.snowy,
            countryCode: countryCode,
          ),
        );
      });

      test('returns correct weather on success (unknown)', () async {
        final MockLocation location = MockLocation();
        final MockWeather weather = MockWeather();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(-1);
        when(() => weatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async => weather);
        final WeatherDomain actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          const WeatherDomain(
            temperature: 42.42,
            location: city,
            condition: WeatherCondition.unknown,
            countryCode: countryCode,
          ),
        );
      });
    });
  });
}
