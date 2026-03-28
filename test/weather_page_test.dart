import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nested/nested.dart';
import 'package:nominatim_api/nominatim_api.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/entities/enums/weather_fetch_origin.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/localization/localization_delegate_getter.dart';
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/router/routes.dart' as router;
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/services/home_widget_service.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/page/weather_page.dart';
import 'package:weather_fit/weather/ui/page/weather_page_default_layout.dart';
import 'package:weather_fit/weather/ui/populated/daily_forecast.dart';
import 'package:weather_fit/weather/ui/widgets/weather_shimmer.dart';
import 'package:weather_fit/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart' as repository;
import 'package:weather_repository/weather_repository.dart';

import 'constants/dummy_constants.dart' as dummy_constants;
import 'helpers/flutter_translate_test_utils.dart';
import 'helpers/hydrated_bloc.dart';
import 'helpers/mocks/mock_blocs.dart';
import 'helpers/mocks/mock_repositories.dart';
import 'helpers/mocks/mock_services.dart';
import 'helpers/mocks/mock_theme_cubit.dart';

class MockLocalDataSource extends Mock implements LocalDataSource {}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _createMockImageHttpClient();
  }
}

HttpClient _createMockImageHttpClient() {
  final MockHttpClient client = MockHttpClient();
  final MockHttpClientRequest request = MockHttpClientRequest();
  final MockHttpClientResponse response = MockHttpClientResponse();
  final MockHttpHeaders headers = MockHttpHeaders();

  when(() => client.getUrl(any())).thenAnswer((_) async => request);
  when(() => request.headers).thenReturn(headers);
  when(() => request.close()).thenAnswer((_) async => response);
  when(() => response.statusCode).thenReturn(HttpStatus.ok);
  when(() => response.contentLength).thenReturn(_transparentSvg.length);
  when(
    () => response.compressionState,
  ).thenReturn(HttpClientResponseCompressionState.notCompressed);
  when(
    () => response.listen(
      any(),
      cancelOnError: any(named: 'cancelOnError'),
      onDone: any(named: 'onDone'),
      onError: any(named: 'onError'),
    ),
  ).thenAnswer((Invocation invocation) {
    final void Function(List<int>) onData =
        invocation.positionalArguments[0] as void Function(List<int>);
    final void Function()? onDone =
        invocation.namedArguments[#onDone] as void Function()?;
    return Stream<List<int>>.fromIterable(<List<int>>[
      _transparentSvg,
    ]).listen(onData, onDone: onDone);
  });
  return client;
}

final List<int> _transparentSvg = utf8.encode(
  '<svg viewBox="0 0 1 1" xmlns="http://www.w3.org/2000/svg"></svg>',
);

void main() {
  HttpOverrides.global = TestHttpOverrides();
  initHydratedStorage();
  late LocalizationDelegate localizationDelegate;
  late MockLocalDataSource mockLocalDataSource;

  setUpAll(() async {
    registerFallbackValue(
      const RefreshWeather(WeatherFetchOrigin.defaultDevice),
    );
    registerFallbackValue(const SearchLocation(''));
    registerFallbackValue(const repository.Location.empty());

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final LocalDataSource localDataSource = LocalDataSource(preferences);
    await setUpFlutterTranslateForTests();
    final Language savedLanguage = localDataSource.getSavedLanguage();
    localizationDelegate = await getLocalizationDelegate(savedLanguage);
  });

  late repository.WeatherRepository weatherRepository;
  late OutfitRepository outfitRepository;
  late HomeWidgetService mockHomeWidgetService;
  late SettingsBloc settingsBloc;
  late ThemeCubit themeCubit;

  setUp(() {
    mockHomeWidgetService = MockHomeWidgetService();
    weatherRepository = MockWeatherRepository();
    outfitRepository = MockOutfitRepository();
    mockLocalDataSource = MockLocalDataSource();

    settingsBloc = MockSettingsBloc();
    themeCubit = MockThemeCubit();

    when(
      () => settingsBloc.state,
    ).thenReturn(const SettingsInitial(language: Language.en));
    when(() => themeCubit.state).thenReturn(ThemeCubit.defaultColor);
    when(
      () => themeCubit.stream,
    ).thenAnswer((_) => const Stream<Color>.empty());

    when(
      () => mockLocalDataSource.getLastSavedLocation(),
    ).thenReturn(const repository.Location.empty());
    when(
      () => mockLocalDataSource.getLastSearchedLocation(),
    ).thenReturn(const repository.Location.empty());
    when(
      () => mockLocalDataSource.getFavouriteLocations(),
    ).thenReturn(<repository.Location>[]);
    when(
      () => mockLocalDataSource.isFavouriteLocation(any()),
    ).thenReturn(false);
    when(() => mockLocalDataSource.getLanguageIsoCode()).thenReturn('en');
    when(
      () => mockLocalDataSource.getCachedWeatherBundle(any()),
    ).thenReturn(null);
    when(
      () => mockLocalDataSource.saveLocation(any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockLocalDataSource.saveLastSearchedLocation(any()),
    ).thenAnswer((_) async => true);
  });

  group('WeatherPage', () {
    testWidgets('renders AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: <SingleChildWidget>[
            RepositoryProvider<repository.WeatherRepository>.value(
              value: weatherRepository,
            ),
            RepositoryProvider<OutfitRepository>.value(value: outfitRepository),
            RepositoryProvider<LocalDataSource>.value(
              value: mockLocalDataSource,
            ),
          ],
          child: MultiBlocProvider(
            providers: <SingleChildWidget>[
              BlocProvider<WeatherBloc>(
                create: (BuildContext _) {
                  return WeatherBloc(
                    weatherRepository: weatherRepository,
                    outfitRepository: outfitRepository,
                    localDataSource: mockLocalDataSource,
                    homeWidgetService: mockHomeWidgetService,
                  );
                },
              ),
              BlocProvider<SearchBloc>(
                create: (BuildContext _) {
                  return SearchBloc(
                    weatherRepository: weatherRepository,
                    locationRepository: LocationRepository(
                      NominatimApiClient(),
                      OpenMeteoApiClient(),
                      mockLocalDataSource,
                    ),
                    localDataSource: mockLocalDataSource,
                  );
                },
              ),
              BlocProvider<SettingsBloc>.value(value: settingsBloc),
            ],
            child: prepareWidgetForTesting(
              LocalizedApp(
                localizationDelegate,
                MaterialApp(
                  initialRoute: AppRoute.weather.path,
                  routes: router.getRouteMap(),
                ),
              ),
              localizationDelegate,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows snack-bar with try again when WeatherFailure occurs', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final WeatherBloc weatherBloc = MockWeatherBloc();
      const String errorMessage = 'Could not get weather information.';

      final Weather weatherWithNoFlag = dummy_constants.dummyWeather.copyWith(
        countryCode: '',
      );

      whenListen(
        weatherBloc,
        Stream<WeatherState>.fromIterable(<WeatherState>[
          WeatherInitial(
            date: DateTime.now(),
            locale: 'en',
            weather: weatherWithNoFlag,
            dailyForecast: const DailyForecastDomain(
              forecast: <ForecastItemDomain>[
                ForecastItemDomain(
                  time: dummy_constants.dummyForecastTime,
                  temperature: dummy_constants.dummyWeatherTemperature,
                  weatherCode: dummy_constants.dummyWeatherCode,
                ),
              ],
            ),
          ),
          WeatherLoadingState(
            date: DateTime.now(),
            locale: 'en',
            weather: weatherWithNoFlag,
          ),
          WeatherFailure(
            date: DateTime.now(),
            message: errorMessage,
            locale: 'en',
            weather: weatherWithNoFlag,
          ),
        ]),
        initialState: WeatherInitial(
          date: DateTime.now(),
          locale: 'en',
          weather: weatherWithNoFlag,
          dailyForecast: const DailyForecastDomain(
            forecast: <ForecastItemDomain>[],
          ),
        ),
      );

      when(() => weatherBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: <SingleChildWidget>[
            RepositoryProvider<repository.WeatherRepository>.value(
              value: weatherRepository,
            ),
            RepositoryProvider<OutfitRepository>.value(value: outfitRepository),
            RepositoryProvider<LocalDataSource>.value(
              value: mockLocalDataSource,
            ),
          ],
          child: MultiBlocProvider(
            providers: <SingleChildWidget>[
              BlocProvider<WeatherBloc>.value(value: weatherBloc),
              BlocProvider<SettingsBloc>.value(value: settingsBloc),
            ],
            child: prepareWidgetForTesting(
              LocalizedApp(
                localizationDelegate,
                const MaterialApp(home: WeatherPage()),
              ),
              localizationDelegate,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final Finder tryAgainFinder = find.text('Try again');
      expect(find.text(errorMessage), findsWidgets);
      expect(tryAgainFinder, findsOneWidget);

      await tester.tapAt(tester.getCenter(tryAgainFinder));

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      verify(
        () => weatherBloc.add(any(that: isA<RefreshWeather>())),
      ).called(greaterThan(0));
    });

    group('WeatherView', () {
      late WeatherBloc weatherBloc;

      setUp(() {
        weatherBloc = MockWeatherBloc();
      });

      testWidgets(
        'default populated layout shows forecast instead of shimmer for '
        'near-identical location coordinates',
        (WidgetTester tester) async {
          final repository.Location selectedLocation = dummy_constants
              .dummyLocation
              .copyWith(latitude: 50.4501, longitude: 30.5234, countryCode: '');
          final repository.Location stateLocation = selectedLocation.copyWith(
            latitude: 50.45015,
            longitude: 30.52345,
          );
          final DateTime futureDate = DateTime.now().add(
            const Duration(days: 1),
          );
          final String futureTimeString =
              '${futureDate.year}-'
              '${futureDate.month.toString().padLeft(2, '0')}'
              '-${futureDate.day.toString().padLeft(2, '0')}T08:00';

          final WeatherSuccess successState = WeatherSuccess(
            date: DateTime.now(),
            locale: dummy_constants.dummyLocale,
            weather: dummy_constants.dummyWeather.copyWith(
              location: stateLocation,
              countryCode: '',
            ),
            outfitRecommendation: 'Wear a jacket',
            dailyForecast: DailyForecastDomain(
              forecast: <ForecastItemDomain>[
                ForecastItemDomain(
                  time: futureTimeString,
                  temperature: 10,
                  weatherCode: 0,
                ),
              ],
            ),
          );

          when(() => weatherBloc.state).thenReturn(successState);
          when(
            () => weatherBloc.stream,
          ).thenAnswer((_) => const Stream<WeatherState>.empty());

          await tester.pumpWidget(
            MultiRepositoryProvider(
              providers: <SingleChildWidget>[
                RepositoryProvider<LocalDataSource>.value(
                  value: mockLocalDataSource,
                ),
              ],
              child: MultiBlocProvider(
                providers: <SingleChildWidget>[
                  BlocProvider<WeatherBloc>.value(value: weatherBloc),
                  BlocProvider<SettingsBloc>.value(value: settingsBloc),
                  BlocProvider<ThemeCubit>.value(value: themeCubit),
                ],
                child: prepareWidgetForTesting(
                  LocalizedApp(
                    localizationDelegate,
                    MaterialApp(
                      home: WeatherPageDefaultLayout(
                        onSettingsPressed: () {},
                        onRefresh: () async {},
                        onSearchPressed: () {},
                        onReportPressed: () {},
                        isEmbedded: true,
                        location: selectedLocation,
                      ),
                    ),
                  ),
                  localizationDelegate,
                ),
              ),
            ),
          );

          await tester.pump();

          expect(find.byType(DailyForecast), findsOneWidget);
          expect(find.byType(DailyForecastShimmer), findsNothing);
        },
      );

      testWidgets('renders WeatherError for WeatherStatus.failure', (
        WidgetTester tester,
      ) async {
        when(() => weatherBloc.state).thenReturn(
          WeatherFailure(
            date: DateTime.now(),
            message: 'Error',
            locale: dummy_constants.dummyLocale,
            weather: Weather.empty,
          ),
        );
        await tester.pumpWidget(
          MultiRepositoryProvider(
            providers: <SingleChildWidget>[
              RepositoryProvider<repository.WeatherRepository>.value(
                value: weatherRepository,
              ),
              RepositoryProvider<LocalDataSource>.value(
                value: mockLocalDataSource,
              ),
            ],
            child: MultiBlocProvider(
              providers: <SingleChildWidget>[
                BlocProvider<WeatherBloc>.value(value: weatherBloc),
                BlocProvider<SettingsBloc>.value(value: settingsBloc),
              ],
              child: prepareWidgetForTesting(
                LocalizedApp(
                  localizationDelegate,
                  const MaterialApp(home: WeatherPage()),
                ),
                localizationDelegate,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(WeatherError), findsOneWidget);
      });
    });

    group('WeatherPage Duplicate Logic', () {
      testWidgets('Swipe list always contains at least one empty location', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MultiRepositoryProvider(
            providers: <SingleChildWidget>[
              RepositoryProvider<repository.WeatherRepository>.value(
                value: weatherRepository,
              ),
              RepositoryProvider<OutfitRepository>.value(
                value: outfitRepository,
              ),
              RepositoryProvider<LocalDataSource>.value(
                value: mockLocalDataSource,
              ),
            ],
            child: MultiBlocProvider(
              providers: <SingleChildWidget>[
                BlocProvider<WeatherBloc>(
                  create: (BuildContext context) => WeatherBloc(
                    weatherRepository: weatherRepository,
                    outfitRepository: outfitRepository,
                    localDataSource: mockLocalDataSource,
                    homeWidgetService: mockHomeWidgetService,
                  ),
                ),
                BlocProvider<SettingsBloc>.value(value: settingsBloc),
              ],
              child: prepareWidgetForTesting(
                LocalizedApp(
                  localizationDelegate,
                  const MaterialApp(home: WeatherPage()),
                ),
                localizationDelegate,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(PageView), findsOneWidget);
      });

      testWidgets(
        'fetches weather for new visible page location when swipe list shrinks',
        (WidgetTester tester) async {
          final repository.Location nonFavouriteLocation = dummy_constants
              .dummyLocation
              .copyWith(
                latitude: 40.7128,
                longitude: -74.0060,
                name: 'New York',
                countryCode: '',
              );
          final repository.Location removedFavouriteLocation = dummy_constants
              .dummyLocation
              .copyWith(
                latitude: 50.4501,
                longitude: 30.5234,
                name: 'Kyiv',
                countryCode: '',
              );

          final List<repository.Location> favourites = <repository.Location>[
            removedFavouriteLocation,
          ];

          when(
            () => mockLocalDataSource.getLastSearchedLocation(),
          ).thenReturn(nonFavouriteLocation);
          when(
            () => mockLocalDataSource.getLastSavedLocation(),
          ).thenReturn(removedFavouriteLocation);
          when(
            () => mockLocalDataSource.getFavouriteLocations(),
          ).thenAnswer((_) => List<repository.Location>.from(favourites));

          final WeatherBloc weatherBloc = MockWeatherBloc();
          final StreamController<WeatherState> controller =
              StreamController<WeatherState>();
          addTearDown(controller.close);
          final Stream<WeatherState> stream = controller.stream
              .asBroadcastStream();

          final WeatherSuccess initialState = WeatherSuccess(
            date: DateTime.now(),
            locale: 'en',
            weather: dummy_constants.dummyWeather.copyWith(
              location: removedFavouriteLocation,
              countryCode: '',
            ),
            outfitRecommendation: 'Test',
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

          when(() => weatherBloc.state).thenReturn(initialState);
          when(() => weatherBloc.stream).thenAnswer((_) => stream);
          when(() => weatherBloc.add(any())).thenReturn(null);

          await tester.pumpWidget(
            MultiRepositoryProvider(
              providers: <SingleChildWidget>[
                RepositoryProvider<repository.WeatherRepository>.value(
                  value: weatherRepository,
                ),
                RepositoryProvider<LocalDataSource>.value(
                  value: mockLocalDataSource,
                ),
              ],
              child: MultiBlocProvider(
                providers: <SingleChildWidget>[
                  BlocProvider<WeatherBloc>.value(value: weatherBloc),
                  BlocProvider<SettingsBloc>.value(value: settingsBloc),
                  BlocProvider<ThemeCubit>.value(value: themeCubit),
                ],
                child: prepareWidgetForTesting(
                  LocalizedApp(
                    localizationDelegate,
                    const MaterialApp(home: WeatherPage()),
                  ),
                  localizationDelegate,
                ),
              ),
            ),
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          favourites.clear();

          controller.add(initialState);
          await tester.pump();
          await tester.pump();

          verify(
            () => weatherBloc.add(
              any(
                that: isA<FetchWeather>().having(
                  (FetchWeather event) => event.location,
                  'location',
                  predicate<repository.Location>(
                    (repository.Location location) =>
                        location.isSamePlaceAs(nonFavouriteLocation),
                  ),
                ),
              ),
            ),
          ).called(greaterThan(0));
        },
      );
    });

    group('UI Stability', () {
      testWidgets('Content does not jump when swiping between locations', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = const Size(800, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final repository.Location loc1 = dummy_constants.dummyLocation.copyWith(
          countryCode: '',
        );
        final repository.Location loc2 = dummy_constants.dummyLocation.copyWith(
          latitude: 40.0,
          longitude: 40.0,
          name: 'Second City',
          countryCode: '',
        );

        when(() => mockLocalDataSource.getLastSavedLocation()).thenReturn(loc1);
        when(
          () => mockLocalDataSource.getLastSearchedLocation(),
        ).thenReturn(loc1);
        when(
          () => mockLocalDataSource.getFavouriteLocations(),
        ).thenReturn(<repository.Location>[loc2]);
        when(
          () => mockLocalDataSource.getCachedWeatherBundle(any()),
        ).thenReturn(null);

        final WeatherBloc weatherBloc = MockWeatherBloc();

        final DateTime futureDate = DateTime.now().add(const Duration(days: 1));
        final String futureTimeString =
            '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}'
            '-${futureDate.day.toString().padLeft(2, '0')}T08:00';

        final WeatherSuccess successState = WeatherSuccess(
          locale: 'en',
          date: DateTime.now(),
          outfitRecommendation: 'Test recommendation',
          weather: dummy_constants.dummyWeather.copyWith(
            location: loc1,
            countryCode: '',
          ),
          dailyForecast: DailyForecastDomain(
            forecast: <ForecastItemDomain>[
              ForecastItemDomain(
                time: futureTimeString,
                temperature: 10,
                weatherCode: 0,
              ),
            ],
          ),
        );

        when(() => weatherBloc.state).thenReturn(successState);
        when(
          () => weatherBloc.stream,
        ).thenAnswer((_) => const Stream<WeatherState>.empty());

        await tester.pumpWidget(
          MultiRepositoryProvider(
            providers: <SingleChildWidget>[
              RepositoryProvider<repository.WeatherRepository>.value(
                value: weatherRepository,
              ),
              RepositoryProvider<LocalDataSource>.value(
                value: mockLocalDataSource,
              ),
            ],
            child: MultiBlocProvider(
              providers: <SingleChildWidget>[
                BlocProvider<WeatherBloc>.value(value: weatherBloc),
                BlocProvider<SettingsBloc>.value(value: settingsBloc),
              ],
              child: prepareWidgetForTesting(
                LocalizedApp(
                  localizationDelegate,
                  const MaterialApp(home: WeatherPage()),
                ),
                localizationDelegate,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        final Finder forecastFinder = find.byType(DailyForecast);
        expect(forecastFinder, findsOneWidget);
        final double initialY = tester.getTopLeft(forecastFinder).dy;

        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pump();

        final Finder shimmerFinder = find.byType(DailyForecastShimmer);
        expect(shimmerFinder, findsWidgets);

        final double shimmerY = tester.getTopLeft(shimmerFinder.first).dy;
        expect(shimmerY, closeTo(initialY, 2.0));
      });
    });
  });
}
