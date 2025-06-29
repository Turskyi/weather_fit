import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nested/nested.dart';
import 'package:nominatim_api/nominatim_api.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/router/routes.dart' as routes;
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/weather.dart';
import 'package:weather_fit/weather/ui/weather_page.dart';
import 'package:weather_repository/weather_repository.dart';

import 'helpers/hydrated_bloc.dart';
import 'helpers/mocks/mock_blocs.dart';
import 'helpers/mocks/mock_repositories.dart';

void main() {
  initHydratedStorage();
  late WeatherRepository weatherRepository;
  late OutfitRepository outfitRepository;
  setUp(() {
    weatherRepository = MockWeatherRepository();
    outfitRepository = MockOutfitRepository();
  });

  group('WeatherPage', () {
    testWidgets('renders AppBar', (WidgetTester tester) async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: MultiBlocProvider(
            providers: <SingleChildWidget>[
              BlocProvider<WeatherBloc>(
                create: (BuildContext _) => WeatherBloc(
                  weatherRepository,
                  outfitRepository,
                  LocalDataSource(preferences),
                ),
              ),
              BlocProvider<SearchBloc>(
                create: (BuildContext _) {
                  final LocalDataSource localDataSource = LocalDataSource(
                    preferences,
                  );
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
            ],
            child: MaterialApp(
              initialRoute: AppRoute.weather.path,
              routes: routes.getRouteMap('en'),
            ),
          ),
        ),
      );
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('WeatherView', () {
    late WeatherBloc weatherBloc;

    setUp(() {
      weatherBloc = MockWeatherBloc();
    });

    testWidgets('renders WeatherLoading for WeatherStatus.initial',
        (WidgetTester tester) async {
      when(() => weatherBloc.state).thenReturn(
        const WeatherLoadingState(),
      );
      await tester.pumpWidget(
        BlocProvider<WeatherBloc>.value(
          value: weatherBloc,
          child: const MaterialApp(home: WeatherPage()),
        ),
      );
      expect(find.byType(WeatherLoadingWidget), findsOneWidget);
    });

    testWidgets('renders WeatherLoading for WeatherStatus.loading',
        (WidgetTester tester) async {
      when(() => weatherBloc.state).thenReturn(const WeatherLoadingState());
      await tester.pumpWidget(
        BlocProvider<WeatherBloc>.value(
          value: weatherBloc,
          child: const MaterialApp(home: WeatherPage()),
        ),
      );
      expect(find.byType(WeatherLoadingWidget), findsOneWidget);
    });

    testWidgets('renders WeatherError for WeatherStatus.failure',
        (WidgetTester tester) async {
      when(() => weatherBloc.state).thenReturn(
        const WeatherFailure(message: 'Error'),
      );
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: BlocProvider<WeatherBloc>.value(
            value: weatherBloc,
            child: const MaterialApp(home: WeatherPage()),
          ),
        ),
      );
      expect(find.byType(WeatherError), findsOneWidget);
    });
  });
}
