import 'package:bloc_test/bloc_test.dart';
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
  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    registerFallbackValue(Uri.parse('http://example.com'));
    registerFallbackValue(dummy_constants.dummyLocation);
    registerFallbackValue(Weather.empty);
  });

  setUp(() async {
    // ...
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
    final LocalDataSource localDataSource = LocalDataSource(preferences);
    weatherBloc = WeatherBloc(
      mockWeatherRepository,
      mockOutfitRepository,
      localDataSource,
      mockHomeWidgetService,
      localDataSource.getLanguageIsoCode(),
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
        () => mockOutfitRepository.getOutfitImageAssetPath(any()),
      ).thenReturn('assets/images/outfits/clear_0.png');

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final LocalDataSource localDataSource = LocalDataSource(preferences);
      weatherBloc = WeatherBloc(
        mockWeatherRepository,
        mockOutfitRepository,
        localDataSource,
        mockHomeWidgetService,
        localDataSource.getLanguageIsoCode(),
      );
    });

    test('initial state is correct', () async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final LocalDataSource localDataSource = LocalDataSource(preferences);
      final String locale = localDataSource.getLanguageIsoCode();
      final WeatherBloc weatherBloc = WeatherBloc(
        mockWeatherRepository,
        mockOutfitRepository,
        localDataSource,
        mockHomeWidgetService,
        locale,
      );
      expect(weatherBloc.state, WeatherInitial(locale: locale));
    });

    group('toJson/fromJson', () {
      test('work properly', () async {
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        final LocalDataSource localDataSource = LocalDataSource(preferences);
        final String locale = localDataSource.getLanguageIsoCode();
        final WeatherBloc weatherBloc = WeatherBloc(
          mockWeatherRepository,
          mockOutfitRepository,
          localDataSource,
          mockHomeWidgetService,
          locale,
        );
        expect(WeatherInitial(locale: locale), weatherBloc.state);
      });
    });

    group('fetchWeather', () {
      group('refreshWeather', () {
        blocTest<WeatherBloc, WeatherState>(
          'emits initial when status is not success',
          build: () => weatherBloc,
          act: (WeatherBloc bloc) {
            bloc.add(const RefreshWeather(WeatherFetchOrigin.wearable));
          },
          expect: () => <Matcher>[
            isA<WeatherState>().having(
              (WeatherState w) => w,
              'state',
              isA<WeatherInitial>(),
            ),
          ],
          verify: (_) => verifyNever(
            () => mockWeatherRepository.getWeatherByLocation(any()),
          ),
        );

        blocTest<WeatherBloc, WeatherState>(
          'emits initial when location is empty',
          build: () => weatherBloc,
          seed: () => const WeatherSuccess(
            weather: Weather.empty,
            locale: dummy_constants.dummyLocale,
          ),
          act: (WeatherBloc bloc) {
            bloc.add(const RefreshWeather(WeatherFetchOrigin.wearable));
          },
          expect: () => <Matcher>[
            isA<WeatherState>().having(
              (WeatherState w) => w,
              'state',
              isA<WeatherInitial>(),
            ),
          ],
          verify: (_) {
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
          seed: () => WeatherLoadingState(
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
          ),
          act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
          expect: () => <WeatherState>[],
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
          ),
          act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
          expect: () => <WeatherState>[
            WeatherSuccess(
              locale: dummy_constants.dummyLocale,
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
          ),
          act: (WeatherBloc bloc) => bloc.add(const ToggleUnits()),
          expect: () => <WeatherState>[
            WeatherSuccess(
              locale: dummy_constants.dummyLocale,
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
  });
}
