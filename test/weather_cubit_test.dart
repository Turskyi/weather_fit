import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_fit/weather/cubit/weather_cubit.dart';
import 'package:weather_fit/weather/models/weather.dart';
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;
import 'package:weather_repository/weather_repository.dart';

import 'helpers/hydrated_bloc.dart';

const String weatherLocation = 'London';
const WeatherCondition weatherCondition = WeatherCondition.rainy;
const double weatherTemperature = 9.8;

class MockWeatherRepository extends Mock
    implements weather_repository.WeatherRepository {}

class MockWeather extends Mock implements weather_repository.WeatherDomain {}

void main() {
  initHydratedStorage();

  group('WeatherCubit', () {
    late WeatherDomain weather;
    late WeatherRepository weatherRepository;
    late WeatherCubit weatherCubit;

    setUp(() async {
      weather = MockWeather();
      weatherRepository = MockWeatherRepository();
      when(() => weather.condition).thenReturn(weatherCondition);
      when(() => weather.location).thenReturn(weatherLocation);
      when(() => weather.temperature).thenReturn(weatherTemperature);
      when(
        () => weatherRepository.getWeather(any()),
      ).thenAnswer((_) async => weather);
      weatherCubit = WeatherCubit(weatherRepository);
    });

    test('initial state is correct', () {
      final WeatherCubit weatherCubit = WeatherCubit(weatherRepository);
      expect(weatherCubit.state, WeatherState());
    });

    group('toJson/fromJson', () {
      test('work properly', () {
        final WeatherCubit weatherCubit = WeatherCubit(weatherRepository);
        expect(
          weatherCubit.fromJson(weatherCubit.toJson(weatherCubit.state)),
          weatherCubit.state,
        );
      });
    });

    group('fetchWeather', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is empty',
        build: () => weatherCubit,
        act: (WeatherCubit cubit) => cubit.fetchWeather(''),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherCubit, WeatherState>(
        'calls getWeather with correct city',
        build: () => weatherCubit,
        act: (WeatherCubit cubit) => cubit.fetchWeather(weatherLocation),
        verify: (_) {
          verify(() => weatherRepository.getWeather(weatherLocation)).called(1);
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, failure] when getWeather throws',
        setUp: () {
          when(
            () => weatherRepository.getWeather(any()),
          ).thenThrow(Exception('oops'));
        },
        build: () => weatherCubit,
        act: (WeatherCubit cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => <WeatherState>[
          WeatherState(status: WeatherStatus.loading),
          WeatherState(status: WeatherStatus.failure),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, success] when getWeather returns (celsius)',
        build: () => weatherCubit,
        act: (WeatherCubit cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => <dynamic>[
          WeatherState(status: WeatherStatus.loading),
          isA<WeatherState>()
              .having(
                (WeatherState w) => w.status,
                'status',
                WeatherStatus.success,
              )
              .having(
                (WeatherState w) => w.weather,
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
                      weatherCondition,
                    )
                    .having(
                      (Weather w) => w.temperature,
                      'temperature',
                      const Temperature(value: weatherTemperature),
                    )
                    .having(
                      (Weather w) => w.location,
                      'location',
                      weatherLocation,
                    ),
              ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, success] when getWeather returns (fahrenheit)',
        build: () => weatherCubit,
        seed: () => WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        act: (WeatherCubit cubit) {
          return cubit.fetchWeather(weatherLocation);
        },
        expect: () {
          DateTime now = DateTime.now();
          String formattedNow = DateFormat('yyyy-MM-dd HH:mm').format(now);
          DateTime parsedDateTime =
              DateFormat('yyyy-MM-dd HH:mm').parse(formattedNow);
          return <dynamic>[
            WeatherState(
              status: WeatherStatus.success,
              temperatureUnits: TemperatureUnits.fahrenheit,
              weather: Weather(
                condition: weatherCondition,
                location: weatherLocation,
                lastUpdated: parsedDateTime,
                temperature: const Temperature(value: 49.64),
              ),
            ),
          ];
        },
      );
    });

    group('refreshWeather', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when status is not success',
        build: () => weatherCubit,
        act: (WeatherCubit cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
        verify: (_) {
          verifyNever(() => weatherRepository.getWeather(any()));
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when location is null',
        build: () => weatherCubit,
        seed: () => WeatherState(status: WeatherStatus.success),
        act: (WeatherCubit cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
        verify: (_) {
          verifyNever(() => weatherRepository.getWeather(any()));
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'invokes getWeather with correct location',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            location: weatherLocation,
            temperature: const Temperature(value: weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: weatherCondition,
          ),
        ),
        act: (WeatherCubit cubit) => cubit.refreshWeather(),
        verify: (_) {
          verify(() => weatherRepository.getWeather(weatherLocation)).called(1);
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when exception is thrown',
        setUp: () {
          when(
            () => weatherRepository.getWeather(any()),
          ).thenThrow(Exception('oops'));
        },
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            location: weatherLocation,
            temperature: const Temperature(value: weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: weatherCondition,
          ),
        ),
        act: (WeatherCubit cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated weather (celsius)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            location: weatherLocation,
            temperature: const Temperature(value: 0),
            lastUpdated: DateTime(2020),
            condition: weatherCondition,
          ),
        ),
        act: (WeatherCubit cubit) => cubit.refreshWeather(),
        expect: () => <Matcher>[
          isA<WeatherState>()
              .having(
                (WeatherState w) => w.status,
                'status',
                WeatherStatus.success,
              )
              .having(
                (WeatherState w) => w.weather,
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
                      weatherCondition,
                    )
                    .having(
                      (Weather w) => w.temperature,
                      'temperature',
                      const Temperature(value: weatherTemperature),
                    )
                    .having(
                      (Weather w) => w.location,
                      'location',
                      weatherLocation,
                    ),
              ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated weather (fahrenheit)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          temperatureUnits: TemperatureUnits.fahrenheit,
          status: WeatherStatus.success,
          weather: Weather(
            location: weatherLocation,
            temperature: const Temperature(value: 0),
            lastUpdated: DateTime(2020),
            condition: weatherCondition,
          ),
        ),
        act: (WeatherCubit cubit) => cubit.refreshWeather(),
        expect: () => <Matcher>[
          isA<WeatherState>()
              .having(
                (WeatherState w) => w.status,
                'status',
                WeatherStatus.success,
              )
              .having(
                (WeatherState w) => w.weather,
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
                      weatherCondition,
                    )
                    .having(
                      (Weather w) => w.temperature,
                      'temperature',
                      Temperature(value: weatherTemperature.toFahrenheit()),
                    )
                    .having(
                      (Weather w) => w.location,
                      'location',
                      weatherLocation,
                    ),
              ),
        ],
      );
    });

    group('toggleUnits', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits updated units when status is not success',
        build: () => weatherCubit,
        act: (WeatherCubit cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated units and temperature '
        'when status is success (celsius)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          temperatureUnits: TemperatureUnits.fahrenheit,
          weather: Weather(
            location: weatherLocation,
            temperature: const Temperature(value: weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: weather_repository.WeatherCondition.rainy,
          ),
        ),
        act: (WeatherCubit cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(
            status: WeatherStatus.success,
            weather: Weather(
              location: weatherLocation,
              temperature: Temperature(value: weatherTemperature.toCelsius()),
              lastUpdated: DateTime(2020),
              condition: weather_repository.WeatherCondition.rainy,
            ),
          ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated units and temperature '
        'when status is success (fahrenheit)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
            location: weatherLocation,
            temperature: const Temperature(value: weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: weather_repository.WeatherCondition.rainy,
          ),
        ),
        act: (WeatherCubit cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(
            status: WeatherStatus.success,
            temperatureUnits: TemperatureUnits.fahrenheit,
            weather: Weather(
              location: weatherLocation,
              temperature: Temperature(
                value: weatherTemperature.toFahrenheit(),
              ),
              lastUpdated: DateTime(2020),
              condition: weather_repository.WeatherCondition.rainy,
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
