import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_fit/data/repositories/ai_repository.dart';
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
  initHydratedStorage();

  group('WeatherBloc', () {
    late WeatherDomain weather;
    late WeatherRepository weatherRepository;
    late AiRepository aiRepository;
    late WeatherBloc weatherBloc;

    setUp(() async {
      weather = MockWeather();
      weatherRepository = MockWeatherRepository();
      aiRepository = MockAiRepository();
      when(() => weather.condition).thenReturn(
        dummy_constants.dummyWeatherCondition,
      );
      when(() => weather.location).thenReturn(
        dummy_constants.dummyWeatherLocation,
      );
      when(() => weather.temperature).thenReturn(
        dummy_constants.dummyWeatherTemperature,
      );
      when(() => weather.countryCode).thenReturn(
        dummy_constants.dummyCountryCode,
      );
      when(
        () => weatherRepository.getWeather(any()),
      ).thenAnswer((_) async => weather);
      weatherBloc = WeatherBloc(weatherRepository, aiRepository);
    });

    test('initial state is correct', () {
      final WeatherBloc weatherBloc = WeatherBloc(
        weatherRepository,
        aiRepository,
      );
      expect(
        weatherBloc.state,
        const WeatherInitial(),
      );
    });

    group('toJson/fromJson', () {
      test('work properly', () {
        final WeatherBloc weatherBloc = WeatherBloc(
          weatherRepository,
          aiRepository,
        );
        expect(
          const WeatherInitial(),
          weatherBloc.state,
        );
      });
    });

    group('fetchWeather', () {
      blocTest<WeatherBloc, WeatherState>(
        'emits initial when city is empty',
        build: () => weatherBloc,
        act: (WeatherBloc bloc) => bloc.add(const FetchWeather(location: '')),
        expect: () => <Matcher>[
          isA<WeatherState>().having(
            (WeatherState w) => w,
            'state',
            isA<WeatherInitial>(),
          ),
        ],
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits [loading, failure] when getWeather throws',
        setUp: () {
          when(
            () => weatherRepository.getWeather(any()),
          ).thenThrow(Exception('oops'));
        },
        build: () => weatherBloc,
        act: (WeatherBloc bloc) => bloc.add(
          const FetchWeather(location: dummy_constants.dummyWeatherLocation),
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
        verify: (_) => verifyNever(() => weatherRepository.getWeather(any())),
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
          verifyNever(() => weatherRepository.getWeather(any()));
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
            location: dummy_constants.dummyWeatherLocation,
            temperature: const Temperature(
              value: dummy_constants.dummyWeatherTemperature,
            ),
            temperatureUnits: TemperatureUnits.celsius,
            countryCode: dummy_constants.dummyCountryCode,
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
            location: dummy_constants.dummyWeatherLocation,
            temperature: const Temperature(
              value: dummy_constants.dummyWeatherTemperature,
            ),
            lastUpdatedDateTime: DateTime(2020),
            condition: WeatherCondition.rainy,
            temperatureUnits: TemperatureUnits.fahrenheit,
            countryCode: dummy_constants.dummyCountryCode,
          ),
        ),
        act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
        expect: () => <WeatherState>[
          WeatherSuccess(
            weather: Weather(
              location: dummy_constants.dummyWeatherLocation,
              temperature: Temperature(
                value: dummy_constants.dummyWeatherTemperature.toCelsius(),
              ),
              lastUpdatedDateTime: DateTime(2020),
              condition: WeatherCondition.rainy,
              temperatureUnits: TemperatureUnits.celsius,
              countryCode: dummy_constants.dummyCountryCode,
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
            location: dummy_constants.dummyWeatherLocation,
            temperature: const Temperature(
              value: dummy_constants.dummyWeatherTemperature,
            ),
            lastUpdatedDateTime: DateTime(2020),
            condition: WeatherCondition.rainy,
            temperatureUnits: TemperatureUnits.celsius,
            countryCode: dummy_constants.dummyCountryCode,
          ),
        ),
        act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
        expect: () => <WeatherState>[
          WeatherSuccess(
            weather: Weather(
              location: dummy_constants.dummyWeatherLocation,
              temperature: Temperature(
                value: dummy_constants.dummyWeatherTemperature.toFahrenheit(),
              ),
              lastUpdatedDateTime: DateTime(2020),
              condition: WeatherCondition.rainy,
              temperatureUnits: TemperatureUnits.fahrenheit,
              countryCode: dummy_constants.dummyCountryCode,
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
