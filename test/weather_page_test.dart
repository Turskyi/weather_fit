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
import 'package:weather_fit/localization/localization_delelegate_getter.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/router/routes.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/services/home_widget_service.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/weather.dart';
import 'package:weather_fit/weather/ui/weather_page.dart';
import 'package:weather_repository/weather_repository.dart';

import 'constants/dummy_constants.dart' as dummy_constants;
import 'helpers/flutter_translate_test_utils.dart';
import 'helpers/hydrated_bloc.dart';
import 'helpers/mocks/mock_blocs.dart';
import 'helpers/mocks/mock_repositories.dart';
import 'helpers/mocks/mock_services.dart';

void main() {
  initHydratedStorage();
  late LocalizationDelegate localizationDelegate;
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final LocalDataSource localDataSource = LocalDataSource(preferences);
    await setUpFlutterTranslateForTests();
    localizationDelegate = await getLocalizationDelegate(
      localDataSource,
    );
  });
  late WeatherRepository weatherRepository;
  late OutfitRepository outfitRepository;
  late HomeWidgetService mockHomeWidgetService;

  late SettingsBloc settingsBloc;
  setUp(() {
    mockHomeWidgetService = MockHomeWidgetService();
    weatherRepository = MockWeatherRepository();
    outfitRepository = MockOutfitRepository();

    settingsBloc = MockSettingsBloc();

    when(() => settingsBloc.state).thenReturn(
      const SettingsInitial(language: Language.en),
    );
  });

  group('WeatherPage', () {
    testWidgets('renders AppBar', (WidgetTester tester) async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: <SingleChildWidget>[
            RepositoryProvider<WeatherRepository>.value(
              value: weatherRepository,
            ),
            RepositoryProvider<OutfitRepository>.value(value: outfitRepository),
          ],
          child: MultiBlocProvider(
            providers: <SingleChildWidget>[
              BlocProvider<WeatherBloc>(
                create: (BuildContext _) {
                  final LocalDataSource localDataSource =
                      LocalDataSource(preferences);
                  return WeatherBloc(
                    weatherRepository,
                    outfitRepository,
                    localDataSource,
                    mockHomeWidgetService,
                    localDataSource.getLanguageIsoCode(),
                  );
                },
              ),
              BlocProvider<SearchBloc>(
                create: (BuildContext _) {
                  final LocalDataSource localDataSource =
                      LocalDataSource(preferences);
                  return SearchBloc(
                    weatherRepository,
                    LocationRepository(
                      NominatimApiClient(),
                      OpenMeteoApiClient(),
                      localDataSource,
                    ),
                    localDataSource,
                  );
                },
              ),
              BlocProvider<SettingsBloc>.value(
                // Provide the mocked SettingsBloc
                value: settingsBloc,
              ),
            ],
            child: prepareWidgetForTesting(
              LocalizedApp(
                localizationDelegate,
                MaterialApp(
                  initialRoute: AppRoute.weather.path,
                  routes: getRouteMap('en'),
                ),
              ),
              localizationDelegate,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('WeatherView', () {
    late WeatherBloc weatherBloc;

    setUp(() {
      weatherBloc = MockWeatherBloc();
    });

    testWidgets('renders WeatherError for WeatherStatus.failure',
        (WidgetTester tester) async {
      when(() => weatherBloc.state).thenReturn(
        const WeatherFailure(
          message: 'Error',
          locale: dummy_constants.dummyLocale,
        ),
      );
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: BlocProvider<WeatherBloc>.value(
            value: weatherBloc,
            child: LocalizedApp(
              localizationDelegate,
              const MaterialApp(
                home: WeatherPage(languageIsoCode: dummy_constants.dummyLocale),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(WeatherError), findsOneWidget);
    });
  });
}
