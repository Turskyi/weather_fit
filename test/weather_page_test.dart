import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nested/nested.dart';
import 'package:weather_fit/data/repositories/ai_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/enums/weather_status.dart';
import 'package:weather_fit/entities/temperature.dart';
import 'package:weather_fit/entities/weather.dart';
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/router/routes.dart' as routes;
import 'package:weather_fit/search/search_page.dart';
import 'package:weather_fit/settings/settings_page.dart';
import 'package:weather_fit/weather/cubit/weather_cubit.dart';
import 'package:weather_fit/weather/ui/weather.dart';
import 'package:weather_fit/weather/ui/weather_page.dart';
import 'package:weather_repository/weather_repository.dart';

import 'helpers/hydrated_bloc.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockAiRepository extends Mock implements AiRepository {}

class MockThemeCubit extends MockCubit<Color> implements ThemeCubit {}

class MockWeatherCubit extends MockCubit<WeatherState>
    implements WeatherCubit {}

void main() {
  initHydratedStorage();
  late WeatherRepository weatherRepository;
  late AiRepository aiRepository;
  setUp(() {
    weatherRepository = MockWeatherRepository();
    aiRepository = MockAiRepository();
  });
  group('WeatherPage', () {
    testWidgets('renders AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: BlocProvider<WeatherCubit>(
            create: (_) => WeatherCubit(weatherRepository, aiRepository),
            child: MaterialApp(
              initialRoute: AppRoute.weather.path,
              routes: routes.routeMap,
            ),
          ),
        ),
      );
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('WeatherView', () {
    final Weather weather = Weather(
      temperature: const Temperature(value: 4.2),
      condition: WeatherCondition.cloudy,
      lastUpdated: DateTime(2020),
      location: 'London',
      temperatureUnits: TemperatureUnits.celsius,
    );
    late ThemeCubit themeCubit;
    late WeatherCubit weatherCubit;

    setUp(() {
      themeCubit = MockThemeCubit();
      weatherCubit = MockWeatherCubit();
    });

    testWidgets('renders WeatherLoading for WeatherStatus.initial',
        (WidgetTester tester) async {
      when(() => weatherCubit.state)
          .thenReturn(WeatherState(status: WeatherStatus.loading));
      await tester.pumpWidget(
        BlocProvider<WeatherCubit>.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherPage()),
        ),
      );
      expect(find.byType(WeatherLoading), findsOneWidget);
    });

    testWidgets('renders WeatherLoading for WeatherStatus.loading',
        (WidgetTester tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.loading,
        ),
      );
      await tester.pumpWidget(
        BlocProvider<WeatherCubit>.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherPage()),
        ),
      );
      expect(find.byType(WeatherLoading), findsOneWidget);
    });

    testWidgets('renders IconButton for WeatherStatus.success',
        (WidgetTester tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather.copyWith(temperatureUnits: TemperatureUnits.celsius),
        ),
      );
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: BlocProvider<WeatherCubit>.value(
            value: weatherCubit,
            child: MaterialApp(
              initialRoute: AppRoute.weather.path,
              routes: routes.routeMap,
            ),
          ),
        ),
      );
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('renders WeatherError for WeatherStatus.failure',
        (WidgetTester tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.failure,
        ),
      );
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: BlocProvider<WeatherCubit>.value(
            value: weatherCubit,
            child: const MaterialApp(home: WeatherPage()),
          ),
        ),
      );
      expect(find.byType(WeatherError), findsOneWidget);
    });

    testWidgets('state is cached', (WidgetTester tester) async {
      when<dynamic>(() => hydratedStorage.read('$WeatherCubit')).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather:
              weather.copyWith(temperatureUnits: TemperatureUnits.fahrenheit),
        ).toJson(),
      );
      await tester.pumpWidget(
        BlocProvider<WeatherCubit>.value(
          value: WeatherCubit(MockWeatherRepository(), MockAiRepository()),
          child: const MaterialApp(home: WeatherPage()),
        ),
      );
      expect(find.byType(WeatherPopulated), findsOneWidget);
    });

    testWidgets('navigates to SettingsPage when settings icon is tapped',
        (WidgetTester tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.loading,
        ),
      );
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: BlocProvider<WeatherCubit>.value(
            value: weatherCubit,
            child: MaterialApp(
              initialRoute: AppRoute.weather.path,
              routes: routes.routeMap,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('navigates to SearchPage when search button is tapped',
        (WidgetTester tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.loading,
        ),
      );
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: BlocProvider<WeatherCubit>.value(
            value: weatherCubit,
            child: MaterialApp(
              initialRoute: AppRoute.weather.path,
              routes: routes.routeMap,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('calls updateTheme when whether changes',
        (WidgetTester tester) async {
      whenListen(
        weatherCubit,
        Stream<WeatherState>.fromIterable(<WeatherState>[
          WeatherState(status: WeatherStatus.loading),
          WeatherState(status: WeatherStatus.success, weather: weather),
        ]),
      );
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
        ),
      );
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: MultiBlocProvider(
            providers: <SingleChildWidget>[
              BlocProvider<ThemeCubit>.value(value: themeCubit),
              BlocProvider<WeatherCubit>.value(value: weatherCubit),
            ],
            child: MaterialApp(
              initialRoute: AppRoute.weather.path,
              routes: routes.routeMap,
            ),
          ),
        ),
      );
      verify(() => themeCubit.updateTheme(weather)).called(1);
    });

    testWidgets('triggers refreshWeather on pull to refresh',
        (WidgetTester tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
        ),
      );
      when(() => weatherCubit.refreshWeather()).thenAnswer((_) async {});
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: BlocProvider<WeatherCubit>.value(
            value: weatherCubit,
            child: MaterialApp(
              initialRoute: AppRoute.weather.path,
              routes: routes.routeMap,
            ),
          ),
        ),
      );
      verifyNever(() => weatherCubit.refreshWeather()).called(0);
    });

    testWidgets('triggers fetch on search pop', (WidgetTester tester) async {
      when(() => weatherCubit.state)
          .thenReturn(WeatherState(status: WeatherStatus.success));
      when(() => weatherCubit.fetchWeather(any())).thenAnswer((_) async {});
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: BlocProvider<WeatherCubit>.value(
            value: weatherCubit,
            child: MaterialApp(
              initialRoute: AppRoute.search.path,
              routes: routes.routeMap,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.enterText(find.byType(TextField), 'Toronto');
      await tester.tap(find.byKey(const Key('searchPage_search_iconButton')));
      verifyNever(() => weatherCubit.fetchWeather('Toronto')).called(0);
    });
  });
}
