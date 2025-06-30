import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

import 'constants/dummy_constants.dart' as dummy_constants;
import 'helpers/hydrated_bloc.dart';
import 'helpers/mocks/mock_entities.dart';
import 'helpers/mocks/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    registerFallbackValue(dummy_constants.dummyLocation);
    registerFallbackValue(Weather.empty);
  });

  initHydratedStorage();

  group('WeatherBloc', () {
    late WeatherDomain weatherDomain;
    late WeatherRepository weatherRepository;
    late OutfitRepository outfitRepository;
    late WeatherBloc weatherBloc;

    setUp(() async {
      weatherDomain = MockWeatherDomain();
      weatherRepository = MockWeatherRepository();
      outfitRepository = MockOutfitRepository();
      when(() => weatherDomain.condition).thenReturn(
        dummy_constants.dummyWeatherCondition,
      );
      when(() => weatherDomain.location).thenReturn(
        dummy_constants.dummyLocation,
      );
      when(() => weatherDomain.temperature).thenReturn(
        dummy_constants.dummyWeatherTemperature,
      );
      when(() => weatherDomain.countryCode).thenReturn(
        dummy_constants.dummyCountryCode,
      );
      when(() => weatherDomain.description).thenReturn(
        dummy_constants.dummyWeatherDescription,
      );
      when(() => weatherDomain.weatherCode).thenReturn(
        dummy_constants.dummyWeatherCode,
      );
      when(() => weatherDomain.locale).thenReturn(
        dummy_constants.dummyLocale,
      );
      when(
        () => weatherRepository.getWeatherByLocation(any()),
      ).thenAnswer((_) async => weatherDomain);

      when(
        () => outfitRepository.getOutfitRecommendation(
          any(),
        ),
      ).thenAnswer((Invocation _) => 'Wear a T-shirt and shorts');

      when(
        () => outfitRepository.getOutfitImageAssetPath(
          any(),
        ),
      ).thenReturn('assets/images/outfits/clear_0.png');

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      weatherBloc = WeatherBloc(
        weatherRepository,
        outfitRepository,
        LocalDataSource(preferences),
      );
    });

    test('initial state is correct', () async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final WeatherBloc weatherBloc = WeatherBloc(
        weatherRepository,
        outfitRepository,
        LocalDataSource(preferences),
      );
      expect(
        weatherBloc.state,
        const WeatherInitial(),
      );
    });

    group('toJson/fromJson', () {
      test('work properly', () async {
        final WeatherBloc weatherBloc = WeatherBloc(
          weatherRepository,
          outfitRepository,
          LocalDataSource(await SharedPreferences.getInstance()),
        );
        expect(
          const WeatherInitial(),
          weatherBloc.state,
        );
      });
    });

    group('fetchWeather', () {
      blocTest<WeatherBloc, WeatherState>(
        'emits loading and success states when FetchWeather is added with '
        'valid location',
        build: () => weatherBloc,
        act: (WeatherBloc bloc) => bloc.add(
          const FetchWeather(location: dummy_constants.dummyLocation),
        ),
        expect: () => <Matcher>[
          isA<WeatherLoadingState>(),
          isA<LoadingOutfitState>(),
          isA<WeatherSuccess>()
              .having(
                (WeatherSuccess s) => s.weather.location.name,
                'location name',
                dummy_constants.dummyLocation.name,
              )
              .having(
                (WeatherSuccess s) => s.outfitRecommendation,
                'outfit recommendation',
                'Wear a T-shirt and shorts',
              )
              .having(
                (WeatherSuccess s) => s.outfitAssetPath,
                'outfit asset path',
                'assets/images/outfits/clear_0.png',
              ),
        ],
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits [loading, failure] when getWeather throws',
        setUp: () {
          when(
            () => weatherRepository.getWeatherByLocation(any()),
          ).thenThrow(Exception('oops'));
        },
        build: () => weatherBloc,
        act: (WeatherBloc bloc) => bloc.add(
          const FetchWeather(location: dummy_constants.dummyLocation),
        ),
        expect: () => <WeatherState>[
          const WeatherLoadingState(),
          WeatherFailure(
            message: '${Exception('oops')}',
          ),
        ],
      );
    });

    group('refreshWeather', () {
      blocTest<WeatherBloc, WeatherState>(
        'emits initial when status is not success',
        build: () => weatherBloc,
        act: (WeatherBloc bloc) => bloc.add(const RefreshWeather()),
        expect: () => <Matcher>[
          isA<WeatherState>().having(
            (WeatherState w) => w,
            'state',
            isA<WeatherInitial>(),
          ),
        ],
        verify: (_) => verifyNever(
          () => weatherRepository.getWeatherByLocation(any()),
        ),
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits initial when location is empty',
        build: () => weatherBloc,
        seed: () => const WeatherSuccess(weather: Weather.empty),
        act: (WeatherBloc bloc) => bloc.add(const RefreshWeather()),
        expect: () => <Matcher>[
          isA<WeatherState>().having(
            (WeatherState w) => w,
            'state',
            isA<WeatherInitial>(),
          ),
        ],
        verify: (_) {
          verifyNever(() => weatherRepository.getWeatherByLocation(any()));
        },
      );
    });

    group('toggleUnits', () {
      blocTest<WeatherBloc, WeatherState>(
        'emits updated units when status is not success',
        build: () => weatherBloc,
        seed: () => WeatherLoadingState(
          weather: Weather(
            condition: WeatherCondition.rainy,
            lastUpdatedDateTime: DateTime(2025),
            location: dummy_constants.dummyLocation,
            temperature: const Temperature(
              value: dummy_constants.dummyWeatherTemperature,
            ),
            temperatureUnits: TemperatureUnits.celsius,
            countryCode: dummy_constants.dummyCountryCode,
            description: '',
            code: 0,
            locale: 'en',
          ),
        ),
        act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits updated units and temperature '
        'when status is success (celsius)',
        build: () => weatherBloc,
        seed: () => WeatherSuccess(
          weather: Weather(
            location: dummy_constants.dummyLocation,
            temperature: const Temperature(
              value: dummy_constants.dummyWeatherTemperature,
            ),
            lastUpdatedDateTime: DateTime(2020),
            condition: WeatherCondition.rainy,
            temperatureUnits: TemperatureUnits.fahrenheit,
            countryCode: dummy_constants.dummyCountryCode,
            description: '',
            code: 0,
            locale: 'en',
          ),
        ),
        act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
        expect: () => <WeatherState>[
          WeatherSuccess(
            weather: Weather(
              location: dummy_constants.dummyLocation,
              temperature: Temperature(
                value: dummy_constants.dummyWeatherTemperature.toCelsius(),
              ),
              lastUpdatedDateTime: DateTime(2020),
              condition: WeatherCondition.rainy,
              temperatureUnits: TemperatureUnits.celsius,
              countryCode: dummy_constants.dummyCountryCode,
              description: '',
              code: 0,
              locale: 'en',
            ),
          ),
        ],
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits updated units and temperature '
        'when status is success (fahrenheit)',
        build: () => weatherBloc,
        seed: () => WeatherSuccess(
          weather: Weather(
            location: dummy_constants.dummyLocation,
            temperature: const Temperature(
              value: dummy_constants.dummyWeatherTemperature,
            ),
            lastUpdatedDateTime: DateTime(2020),
            condition: WeatherCondition.rainy,
            temperatureUnits: TemperatureUnits.celsius,
            countryCode: dummy_constants.dummyCountryCode,
            description: '',
            code: 0,
            locale: 'en',
          ),
        ),
        act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
        expect: () => <WeatherState>[
          WeatherSuccess(
            weather: Weather(
              location: dummy_constants.dummyLocation,
              temperature: Temperature(
                value: dummy_constants.dummyWeatherTemperature.toFahrenheit(),
              ),
              lastUpdatedDateTime: DateTime(2020),
              condition: WeatherCondition.rainy,
              temperatureUnits: TemperatureUnits.fahrenheit,
              countryCode: dummy_constants.dummyCountryCode,
              description: '',
              code: 0,
              locale: 'en',
            ),
          ),
        ],
      );
    });
  });
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;

  double toCelsius() => (this - 32) * 5 / 9;
}
