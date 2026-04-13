import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/enums/weather_fetch_origin.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/services/home_widget_service.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

import 'constants/dummy_constants.dart' as dummy_constants;
import 'helpers/hydrated_bloc.dart';
import 'helpers/mocks/mock_entities.dart';
import 'helpers/mocks/mock_repositories.dart';
import 'helpers/mocks/mock_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HomeWidgetService mockHomeWidgetService;
  late WeatherBloc weatherBloc;
  late WeatherRepository mockWeatherRepository;
  late OutfitRepository mockOutfitRepository;
  late LocalDataSource localDataSource;

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    registerFallbackValue(Uri.parse('http://example.com'));
    registerFallbackValue(dummy_constants.dummyLocation);
    registerFallbackValue(Weather.empty);
    registerFallbackValue(
      const DailyForecastDomain(forecast: <ForecastItemDomain>[]),
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    mockHomeWidgetService = MockHomeWidgetService();
    mockWeatherRepository = MockWeatherRepository();
    mockOutfitRepository = MockOutfitRepository();
    // Stub the methods of mockHomeWidgetService that will be called.
    when(
      () => mockHomeWidgetService.setAppGroupId(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockHomeWidgetService.saveWidgetData<String>(any(), any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockHomeWidgetService.updateWidget(
        iOSName: any(named: 'iOSName'),
        androidName: any(named: 'androidName'),
      ),
    ).thenAnswer((_) async => true);

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    localDataSource = LocalDataSource(preferences);
    when(
      () => mockHomeWidgetService.updateHomeWidget(
        localDataSource: localDataSource,
        weather: any(named: 'weather'),
        forecast: any(named: 'forecast'),
        outfitRepository: mockOutfitRepository,
      ),
    ).thenAnswer((_) async {});

    weatherBloc = WeatherBloc(
      weatherRepository: mockWeatherRepository,
      outfitRepository: mockOutfitRepository,
      localDataSource: localDataSource,
      homeWidgetService: mockHomeWidgetService,
    );
  });

  initHydratedStorage();

  group('WeatherBloc', () {
    late WeatherDomain weatherDomain;

    setUp(() async {
      weatherDomain = MockWeatherDomain();

      when(
        () => weatherDomain.condition,
      ).thenReturn(dummy_constants.dummyWeatherCondition);
      when(
        () => weatherDomain.location,
      ).thenReturn(dummy_constants.dummyLocation);
      when(
        () => weatherDomain.temperature,
      ).thenReturn(dummy_constants.dummyWeatherTemperature);
      when(
        () => weatherDomain.countryCode,
      ).thenReturn(dummy_constants.dummyCountryCode);
      when(
        () => weatherDomain.description,
      ).thenReturn(dummy_constants.dummyWeatherDescription);
      when(
        () => weatherDomain.weatherCode,
      ).thenReturn(dummy_constants.dummyWeatherCode);
      when(() => weatherDomain.locale).thenReturn(dummy_constants.dummyLocale);
      when(
        () => mockWeatherRepository.getWeatherByLocation(any()),
      ).thenAnswer((_) async => weatherDomain);

      when(
        () => mockOutfitRepository.getOutfitRecommendation(any()),
      ).thenAnswer((Invocation _) => 'Wear a T-shirt and shorts');

      when(
        () => mockOutfitRepository.getOutfitImageAssetPaths(any()),
      ).thenReturn(<String>['assets/images/outfits/clear_0.png']);

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      localDataSource = LocalDataSource(preferences);
      when(
        () => mockHomeWidgetService.updateHomeWidget(
          localDataSource: localDataSource,
          weather: any(named: 'weather'),
          forecast: any(named: 'forecast'),
          outfitRepository: mockOutfitRepository,
        ),
      ).thenAnswer((_) async {});

      weatherBloc = WeatherBloc(
        weatherRepository: mockWeatherRepository,
        outfitRepository: mockOutfitRepository,
        localDataSource: localDataSource,
        homeWidgetService: mockHomeWidgetService,
      );
    });

    test('initial state is correct', () async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final LocalDataSource localDataSource = LocalDataSource(preferences);
      final String locale = localDataSource.getLanguageIsoCode();
      final WeatherBloc weatherBloc = WeatherBloc(
        weatherRepository: mockWeatherRepository,
        outfitRepository: mockOutfitRepository,
        localDataSource: localDataSource,
        homeWidgetService: mockHomeWidgetService,
      );
      expect(weatherBloc.state.locale, locale);
      expect(weatherBloc.state, isA<WeatherInitial>());
      expect(weatherBloc.state.dailyForecast?.forecast, isEmpty);
      expect(
        weatherBloc.state.weather.temperatureUnits,
        localDataSource.getTemperatureUnits(),
      );
    });

    group('persistence', () {
      blocTest<WeatherBloc, WeatherState>(
        'ToggleUnits saves units to localDataSource',
        build: () => weatherBloc,
        act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
        verify: (_) {
          expect(
            localDataSource.getTemperatureUnits(),
            TemperatureUnits.fahrenheit,
          );
        },
      );

      test('initializes with units from localDataSource', () async {
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        final LocalDataSource localDataSource = LocalDataSource(preferences);
        await localDataSource.saveTemperatureUnits(TemperatureUnits.fahrenheit);

        final WeatherBloc weatherBloc = WeatherBloc(
          weatherRepository: mockWeatherRepository,
          outfitRepository: mockOutfitRepository,
          localDataSource: localDataSource,
          homeWidgetService: mockHomeWidgetService,
        );

        expect(
          weatherBloc.state.weather.temperatureUnits,
          TemperatureUnits.fahrenheit,
        );
      });
    });

    group('toJson/fromJson', () {
      test('work properly', () async {
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        final LocalDataSource localDataSource = LocalDataSource(preferences);
        final String locale = localDataSource.getLanguageIsoCode();
        final WeatherBloc weatherBloc = WeatherBloc(
          weatherRepository: mockWeatherRepository,
          outfitRepository: mockOutfitRepository,
          localDataSource: localDataSource,
          homeWidgetService: mockHomeWidgetService,
        );
        expect(weatherBloc.state.locale, locale);
        expect(weatherBloc.state, isA<WeatherInitial>());
      });
    });

    group('fetchWeather', () {
      group('updateWeatherOnHomeWidget', () {
        blocTest<WeatherBloc, WeatherState>(
          'does not emit errors when home widget update throws '
          'PlatformException',
          build: () => weatherBloc,
          setUp: () {
            when(
              () => mockHomeWidgetService.updateHomeWidget(
                localDataSource: localDataSource,
                weather: any(named: 'weather'),
                forecast: any(named: 'forecast'),
                outfitRepository: mockOutfitRepository,
              ),
            ).thenThrow(
              PlatformException(
                code: 'error',
                message: 'Widget API not available',
              ),
            );
          },
          seed: () => WeatherSuccess(
            locale: dummy_constants.dummyLocale,
            weather: Weather.empty,
            dailyForecast: const DailyForecastDomain(
              forecast: <ForecastItemDomain>[
                ForecastItemDomain(
                  time: '2030-01-01T13:00:00',
                  temperature: 20,
                  weatherCode: 1,
                ),
              ],
            ),
            date: DateTime(2025),
          ),
          act: (WeatherBloc bloc) {
            bloc.add(
              const UpdateWeatherOnHomeWidgetEvent(
                WeatherFetchOrigin.defaultDevice,
              ),
            );
          },
          expect: () => <WeatherState>[],
          verify: (_) {
            verify(
              () => mockHomeWidgetService.updateHomeWidget(
                localDataSource: localDataSource,
                weather: any(named: 'weather'),
                forecast: any(named: 'forecast'),
                outfitRepository: mockOutfitRepository,
              ),
            ).called(1);
          },
        );
      });

      group('refreshWeather', () {
        blocTest<WeatherBloc, WeatherState>(
          'emits initial when status is not success',
          build: () => weatherBloc,
          act: (WeatherBloc bloc) {
            bloc.add(const RefreshWeather(WeatherFetchOrigin.wearable));
          },
          expect: () => <Matcher>[isA<WeatherInitial>()],
          verify: (_) => verifyNever(
            () => mockWeatherRepository.getWeatherByLocation(any()),
          ),
        );

        blocTest<WeatherBloc, WeatherState>(
          'emits initial when location is empty',
          build: () => weatherBloc,
          seed: () {
            return WeatherSuccess(
              weather: Weather.empty,
              locale: dummy_constants.dummyLocale,
              dailyForecast: const DailyForecastDomain(
                forecast: <ForecastItemDomain>[
                  ForecastItemDomain(
                    time: dummy_constants.dummyForecastTime,
                    temperature: dummy_constants.dummyWeatherTemperature,
                    weatherCode: dummy_constants.dummyWeatherCode,
                  ),
                ],
              ),
              date: DateTime(2025),
            );
          },
          act: (WeatherBloc bloc) {
            bloc.add(const RefreshWeather(WeatherFetchOrigin.wearable));
          },
          expect: () => <Matcher>[isA<WeatherInitial>()],
          verify: (_) {
            verifyNever(
              () => mockWeatherRepository.getWeatherByLocation(any()),
            );
          },
        );
      });

      group('stale location guards', () {
        const Location otherLocation = Location(
          latitude: 40.7128,
          longitude: -74.0060,
          locale: 'en',
          name: 'New York',
          countryCode: 'US',
          country: 'United States',
        );
        const DailyForecastDomain dailyForecast = DailyForecastDomain(
          forecast: <ForecastItemDomain>[
            ForecastItemDomain(
              time: dummy_constants.dummyForecastTime,
              temperature: dummy_constants.dummyWeatherTemperature,
              weatherCode: dummy_constants.dummyWeatherCode,
            ),
          ],
        );

        blocTest<WeatherBloc, WeatherState>(
          'ignores fetch when event location is not selected location',
          build: () => weatherBloc,
          act: (WeatherBloc bloc) async {
            await localDataSource.saveLocation(dummy_constants.dummyLocation);
            bloc.add(
              const FetchWeather(
                location: otherLocation,
                origin: WeatherFetchOrigin.defaultDevice,
              ),
            );
          },
          expect: () => <WeatherState>[],
          verify: (_) {
            verifyNever(() => mockWeatherRepository.getDailyForecast(any()));
            verifyNever(
              () => mockWeatherRepository.getWeatherByLocation(any()),
            );
          },
        );

        blocTest<WeatherBloc, WeatherState>(
          'does not emit success when selected location changes mid-fetch',
          build: () => weatherBloc,
          setUp: () {
            final Completer<DailyForecastDomain> completer =
                Completer<DailyForecastDomain>();
            when(
              () => mockWeatherRepository.getDailyForecast(
                dummy_constants.dummyLocation,
              ),
            ).thenAnswer((_) => completer.future);

            Future<void>.microtask(() async {
              await localDataSource.saveLocation(dummy_constants.dummyLocation);
              await Future<void>.delayed(Duration.zero);
              await localDataSource.saveLocation(otherLocation);
              completer.complete(dailyForecast);
            });
          },
          act: (WeatherBloc bloc) {
            bloc.add(
              const FetchWeather(
                location: dummy_constants.dummyLocation,
                origin: WeatherFetchOrigin.defaultDevice,
              ),
            );
          },
          expect: () => <Matcher>[isA<WeatherLoadingState>()],
          verify: (_) {
            verify(
              () => mockWeatherRepository.getDailyForecast(
                dummy_constants.dummyLocation,
              ),
            ).called(1);
            verifyNever(
              () => mockWeatherRepository.getWeatherByLocation(any()),
            );
          },
        );
      });

      group('toggleUnits', () {
        blocTest<WeatherBloc, WeatherState>(
          'emits updated units when status is not success',
          build: () => weatherBloc,
          seed: () {
            return WeatherLoadingState(
              locale: dummy_constants.dummyLocale,
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
              date: DateTime.now(),
            );
          },
          act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
          expect: () => <Matcher>[
            isA<WeatherLoadingState>().having(
              (WeatherLoadingState s) => s.weather.temperatureUnits,
              'units',
              TemperatureUnits.fahrenheit,
            ),
          ],
        );

        blocTest<WeatherBloc, WeatherState>(
          'emits updated units and temperature '
          'when status is success (celsius)',
          build: () => weatherBloc,
          seed: () => WeatherSuccess(
            locale: dummy_constants.dummyLocale,
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
            dailyForecast: const DailyForecastDomain(
              forecast: <ForecastItemDomain>[
                ForecastItemDomain(
                  time: dummy_constants.dummyForecastTime,
                  temperature: dummy_constants.dummyWeatherTemperature,
                  weatherCode: dummy_constants.dummyWeatherCode,
                ),
              ],
            ),
            date: DateTime(2025),
          ),
          act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
          expect: () {
            return <Matcher>[
              isA<WeatherSuccess>()
                  .having(
                    (WeatherSuccess s) => s.weather.temperatureUnits,
                    'units',
                    TemperatureUnits.celsius,
                  )
                  .having(
                    (WeatherSuccess s) => s.weather.temperature.value,
                    'value',
                    dummy_constants.dummyWeatherTemperature.toCelsius(),
                  ),
            ];
          },
        );

        blocTest<WeatherBloc, WeatherState>(
          'emits updated units and temperature '
          'when status is success (Fahrenheit)',
          build: () => weatherBloc,
          seed: () {
            return WeatherSuccess(
              date: DateTime(2025),
              locale: dummy_constants.dummyLocale,
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
              dailyForecast: const DailyForecastDomain(
                forecast: <ForecastItemDomain>[
                  ForecastItemDomain(
                    time: dummy_constants.dummyForecastTime,
                    temperature: dummy_constants.dummyWeatherTemperature,
                    weatherCode: dummy_constants.dummyWeatherCode,
                  ),
                ],
              ),
            );
          },
          act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
          expect: () => <Matcher>[
            isA<WeatherSuccess>()
                .having(
                  (WeatherSuccess s) => s.weather.temperatureUnits,
                  'units',
                  TemperatureUnits.fahrenheit,
                )
                .having(
                  (WeatherSuccess s) => s.weather.temperature.value,
                  'value',
                  dummy_constants.dummyWeatherTemperature.toFahrenheit(),
                ),
          ],
        );
      });

      group('home widget update', () {
        blocTest<WeatherBloc, WeatherState>(
          'invokes HomeWidgetService when update event is dispatched and '
          'forecast exists',
          build: () => weatherBloc,
          seed: () => WeatherSuccess(
            locale: dummy_constants.dummyLocale,
            weather: Weather(
              location: dummy_constants.dummyLocation,
              temperature: const Temperature(
                value: dummy_constants.dummyWeatherTemperature,
              ),
              lastUpdatedDateTime: DateTime(2025),
              condition: WeatherCondition.clear,
              temperatureUnits: TemperatureUnits.celsius,
              countryCode: dummy_constants.dummyCountryCode,
              description: dummy_constants.dummyWeatherDescription,
              code: dummy_constants.dummyWeatherCode,
              locale: dummy_constants.dummyLocale,
            ),
            dailyForecast: const DailyForecastDomain(
              forecast: <ForecastItemDomain>[
                ForecastItemDomain(
                  time: dummy_constants.dummyForecastTime,
                  temperature: dummy_constants.dummyWeatherTemperature,
                  weatherCode: dummy_constants.dummyWeatherCode,
                ),
              ],
            ),
            date: DateTime(2025),
          ),
          act: (WeatherBloc bloc) => bloc.add(
            const UpdateWeatherOnHomeWidgetEvent(
              WeatherFetchOrigin.defaultDevice,
            ),
          ),
          expect: () => <WeatherState>[],
          verify: (_) {
            verify(
              () => mockHomeWidgetService.updateHomeWidget(
                localDataSource: localDataSource,
                weather: any(named: 'weather'),
                forecast: any(named: 'forecast'),
                outfitRepository: mockOutfitRepository,
              ),
            ).called(1);
          },
        );

        blocTest<WeatherBloc, WeatherState>(
          'does not invoke HomeWidgetService when forecast is missing',
          build: () => weatherBloc,
          seed: () => WeatherInitial(
            locale: dummy_constants.dummyLocale,
            weather: Weather(
              location: dummy_constants.dummyLocation,
              temperature: const Temperature(
                value: dummy_constants.dummyWeatherTemperature,
              ),
              lastUpdatedDateTime: DateTime(2025),
              condition: WeatherCondition.clear,
              temperatureUnits: TemperatureUnits.celsius,
              countryCode: dummy_constants.dummyCountryCode,
              description: dummy_constants.dummyWeatherDescription,
              code: dummy_constants.dummyWeatherCode,
              locale: dummy_constants.dummyLocale,
            ),
            dailyForecast: null,
            date: DateTime(2025),
          ),
          act: (WeatherBloc bloc) => bloc.add(
            const UpdateWeatherOnHomeWidgetEvent(
              WeatherFetchOrigin.defaultDevice,
            ),
          ),
          expect: () => <WeatherState>[],
          verify: (_) {
            verifyNever(
              () => mockHomeWidgetService.updateHomeWidget(
                localDataSource: localDataSource,
                weather: any(named: 'weather'),
                forecast: any(named: 'forecast'),
                outfitRepository: mockOutfitRepository,
              ),
            );
          },
        );
      });
    });
  });
}
