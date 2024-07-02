import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_fit/data/repositories/ai_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/temperature.dart';
import 'package:weather_fit/entities/weather.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;
import 'package:weather_repository/weather_repository.dart';

import 'helpers/hydrated_bloc.dart';

const String _weatherLocation = 'London';
const WeatherCondition _weatherCondition = WeatherCondition.rainy;
const double _weatherTemperature = 9.8;
const String _countryCode = 'gb';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockAiRepository extends Mock implements AiRepository {}

class MockWeather extends Mock implements WeatherDomain {}

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
      when(() => weather.condition).thenReturn(_weatherCondition);
      when(() => weather.location).thenReturn(_weatherLocation);
      when(() => weather.temperature).thenReturn(_weatherTemperature);
      when(
        () => weatherRepository.getWeather(any()),
      ).thenAnswer((_) async => weather);
      weatherBloc = WeatherBloc(weatherRepository, aiRepository);
    });

    test('initial state is correct', () {
      final WeatherBloc weatherBloc =
          WeatherBloc(weatherRepository, aiRepository);
      expect(
        weatherBloc.state,
        const WeatherInitial(),
      );
    });

    group('toJson/fromJson', () {
      test('work properly', () {
        final WeatherBloc weatherBloc =
            WeatherBloc(weatherRepository, aiRepository);
        expect(
          weatherBloc.fromJson(weatherBloc.toJson(weatherBloc.state)),
          weatherBloc.state,
        );
      });
    });

    group('fetchWeather', () {
      blocTest<WeatherBloc, WeatherState>(
        'emits initial when city is empty',
        build: () => weatherBloc,
        act: (WeatherBloc bloc) => bloc.add(const FetchWeather(city: '')),
        expect: () => <Matcher>[
          isA<WeatherState>().having(
            (WeatherState w) => w,
            'state',
            isA<WeatherInitial>(),
          ),
        ],
      );

      blocTest<WeatherBloc, WeatherState>(
        'calls getWeather with correct city',
        build: () => weatherBloc,
        act: (WeatherBloc bloc) =>
            bloc.add(const FetchWeather(city: _weatherLocation)),
        verify: (_) {
          verify(() => weatherRepository.getWeather(_weatherLocation))
              .called(1);
        },
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits [loading, failure] when getWeather throws',
        setUp: () {
          when(
            () => weatherRepository.getWeather(any()),
          ).thenThrow(Exception('oops'));
        },
        build: () => weatherBloc,
        act: (WeatherBloc bloc) =>
            bloc.add(const FetchWeather(city: _weatherLocation)),
        expect: () => <WeatherState>[
          const WeatherLoadingState(),
          WeatherFailure(message: '${Exception('oops')}'),
        ],
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits [loading, success] when getWeather returns (celsius)',
        build: () => weatherBloc,
        act: (WeatherBloc bloc) =>
            bloc.add(const FetchWeather(city: _weatherLocation)),
        expect: () => <dynamic>[
          const WeatherLoadingState(),
          isA<WeatherSuccess>(),
        ],
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits [loading, success] when getWeather returns (fahrenheit)',
        build: () => weatherBloc,
        seed: () => WeatherSuccess(
          weather: Weather.fromRepository(weather)
              .copyWith(temperatureUnits: TemperatureUnits.fahrenheit),
        ),
        act: (WeatherBloc bloc) =>
            bloc.add(const FetchWeather(city: _weatherLocation)),
        expect: () {
          return <dynamic>[
            const WeatherLoadingState(),
            isA<WeatherSuccess>(),
          ];
        },
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

      blocTest<WeatherBloc, WeatherState>(
        'invokes getWeather with correct location',
        build: () => weatherBloc,
        seed: () => WeatherSuccess(
          weather: Weather(
            city: _weatherLocation,
            temperature: const Temperature(value: _weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: _weatherCondition,
            temperatureUnits: TemperatureUnits.celsius,
            countryCode: _countryCode,
          ),
        ),
        act: (WeatherBloc bloc) => bloc.add(const RefreshWeather()),
        verify: (_) {
          verify(() => weatherRepository.getWeather(_weatherLocation))
              .called(1);
        },
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits nothing when exception is thrown',
        setUp: () {
          when(
            () => weatherRepository.getWeather(any()),
          ).thenThrow(Exception('oops'));
        },
        build: () => weatherBloc,
        seed: () => WeatherSuccess(
          weather: Weather(
            city: _weatherLocation,
            temperature: const Temperature(value: _weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: _weatherCondition,
            temperatureUnits: TemperatureUnits.celsius,
            countryCode: _countryCode,
          ),
        ),
        act: (WeatherBloc bloc) => bloc.add(const RefreshWeather()),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits updated weather (celsius)',
        build: () => weatherBloc,
        seed: () => WeatherSuccess(
          weather: Weather(
            city: _weatherLocation,
            temperature: const Temperature(value: 0),
            lastUpdated: DateTime(2020),
            condition: _weatherCondition,
            temperatureUnits: TemperatureUnits.celsius,
            countryCode: _countryCode,
          ),
        ),
        act: (WeatherBloc bloc) => bloc.add(const RefreshWeather()),
        expect: () => <Matcher>[
          isA<WeatherState>()
              .having(
                (WeatherState w) => w,
                'state',
                isA<WeatherSuccess>(),
              )
              .having(
                (WeatherState w) => (w as WeatherSuccess).weather,
                'weather',
                isA<Weather>()
                    .having(
                      (Weather w) => w.lastUpdated,
                      'lastUpdated',
                      isNotNull,
                    )
                    .having(
                      (Weather w) => w.condition,
                      'condition',
                      _weatherCondition,
                    )
                    .having(
                      (Weather w) => w.temperature,
                      'temperature',
                      const Temperature(value: _weatherTemperature),
                    )
                    .having(
                      (Weather w) => w.city,
                      'location',
                      _weatherLocation,
                    ),
              ),
        ],
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits updated weather (fahrenheit)',
        build: () => weatherBloc,
        seed: () => WeatherSuccess(
          weather: Weather(
            city: _weatherLocation,
            temperature: const Temperature(value: 0),
            lastUpdated: DateTime(2020),
            condition: _weatherCondition,
            temperatureUnits: TemperatureUnits.fahrenheit,
            countryCode: _countryCode,
          ),
        ),
        act: (WeatherBloc bloc) => bloc.add(const RefreshWeather()),
        expect: () => <Matcher>[
          isA<WeatherState>()
              .having(
                (WeatherState w) => w,
                'state',
                isA<WeatherSuccess>(),
              )
              .having(
                (WeatherState w) => (w as WeatherSuccess).weather,
                'weather',
                isA<Weather>()
                    .having(
                      (Weather w) => w.lastUpdated,
                      'lastUpdated',
                      isNotNull,
                    )
                    .having(
                      (Weather w) => w.condition,
                      'condition',
                      _weatherCondition,
                    )
                    .having(
                      (Weather w) => w.temperature,
                      'temperature',
                      Temperature(value: _weatherTemperature.toFahrenheit()),
                    )
                    .having(
                      (Weather w) => w.city,
                      'location',
                      _weatherLocation,
                    ),
              ),
        ],
      );
    });
    group('toggleUnits', () {
      blocTest<WeatherBloc, WeatherState>(
        'emits updated units when status is not success',
        build: () => weatherBloc,
        seed: () => WeatherLoadingState(
          weather: Weather(
            condition: weather_repository.WeatherCondition.rainy,
            lastUpdated: DateTime(2025),
            city: _weatherLocation,
            temperature: const Temperature(value: _weatherTemperature),
            temperatureUnits: TemperatureUnits.celsius,
            countryCode: _countryCode,
          ),
        ),
        act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
        expect: () => <WeatherState>[
          WeatherLoadingState(
            weather: Weather.fromRepository(weather).copyWith(
              temperatureUnits: TemperatureUnits.fahrenheit,
              lastUpdated: DateTime(2025),
            ),
          ),
        ],
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits updated units and temperature '
        'when status is success (celsius)',
        build: () => weatherBloc,
        seed: () => WeatherSuccess(
          weather: Weather(
            city: _weatherLocation,
            temperature: const Temperature(value: _weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: weather_repository.WeatherCondition.rainy,
            temperatureUnits: TemperatureUnits.fahrenheit,
            countryCode: _countryCode,
          ),
        ),
        act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
        expect: () => <WeatherState>[
          WeatherSuccess(
            weather: Weather(
              city: _weatherLocation,
              temperature: Temperature(value: _weatherTemperature.toCelsius()),
              lastUpdated: DateTime(2020),
              condition: weather_repository.WeatherCondition.rainy,
              temperatureUnits: TemperatureUnits.celsius,
              countryCode: _countryCode,
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
            city: _weatherLocation,
            temperature: const Temperature(value: _weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: weather_repository.WeatherCondition.rainy,
            temperatureUnits: TemperatureUnits.celsius,
            countryCode: _countryCode,
          ),
        ),
        act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
        expect: () => <WeatherState>[
          WeatherSuccess(
            weather: Weather(
              city: _weatherLocation,
              temperature: Temperature(
                value: _weatherTemperature.toFahrenheit(),
              ),
              lastUpdated: DateTime(2020),
              condition: weather_repository.WeatherCondition.rainy,
              temperatureUnits: TemperatureUnits.fahrenheit,
              countryCode: _countryCode,
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
