import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nested/nested.dart';
import 'package:weather_fit/search/search_page.dart';
import 'package:weather_fit/settings/settings_page.dart';
import 'package:weather_fit/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/weather/cubit/weather_cubit.dart';
import 'package:weather_fit/weather/models/weather.dart';
import 'package:weather_fit/weather/ui/weather.dart';
import 'package:weather_fit/weather/ui/weather_page.dart';
import 'package:weather_fit/weather/ui/weather_view.dart';
import 'package:weather_repository/weather_repository.dart' hide WeatherDomain;

import 'helpers/hydrated_bloc.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockThemeCubit extends MockCubit<Color> implements ThemeCubit {}

class MockWeatherCubit extends MockCubit<WeatherState>
    implements WeatherCubit {}

void main() {
  initHydratedStorage();

  group('WeatherPage', () {
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherRepository = MockWeatherRepository();
    });

    testWidgets('renders WeatherView', (WidgetTester tester) async {
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: const MaterialApp(home: WeatherPage()),
        ),
      );
      expect(find.byType(WeatherView), findsOneWidget);
    });
  });

  group('WeatherView', () {
    final Weather weather = Weather(
      temperature: const Temperature(value: 4.2),
      condition: WeatherCondition.cloudy,
      lastUpdated: DateTime(2020),
      location: 'London',
    );
    late ThemeCubit themeCubit;
    late WeatherCubit weatherCubit;

    setUp(() {
      themeCubit = MockThemeCubit();
      weatherCubit = MockWeatherCubit();
    });

    testWidgets('renders WeatherLoading for WeatherStatus.initial',
        (WidgetTester tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(
        BlocProvider<WeatherCubit>.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
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
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(WeatherLoading), findsOneWidget);
    });

    testWidgets('renders WeatherPopulated for WeatherStatus.success',
        (WidgetTester tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
        ),
      );
      await tester.pumpWidget(
        BlocProvider<WeatherCubit>.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(WeatherPopulated), findsOneWidget);
    });

    testWidgets('renders WeatherError for WeatherStatus.failure',
        (WidgetTester tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.failure,
        ),
      );
      await tester.pumpWidget(
        BlocProvider<WeatherCubit>.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(WeatherError), findsOneWidget);
    });

    testWidgets('state is cached', (WidgetTester tester) async {
      when<dynamic>(() => hydratedStorage.read('$WeatherCubit')).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
          temperatureUnits: TemperatureUnits.fahrenheit,
        ).toJson(),
      );
      await tester.pumpWidget(
        BlocProvider<WeatherCubit>.value(
          value: WeatherCubit(MockWeatherRepository()),
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      expect(find.byType(WeatherPopulated), findsOneWidget);
    });

    testWidgets('navigates to SettingsPage when settings icon is tapped',
        (WidgetTester tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(
        BlocProvider<WeatherCubit>.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('navigates to SearchPage when search button is tapped',
        (WidgetTester tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(
        BlocProvider<WeatherCubit>.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
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
          WeatherState(),
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
        MultiBlocProvider(
          providers: <SingleChildWidget>[
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<WeatherCubit>.value(value: weatherCubit),
          ],
          child: const MaterialApp(home: WeatherView()),
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
        BlocProvider<WeatherCubit>.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      await tester.fling(
        find.text('London'),
        const Offset(0, 500),
        1000,
      );
      await tester.pumpAndSettle();
      verify(() => weatherCubit.refreshWeather()).called(1);
    });

    testWidgets('triggers fetch on search pop', (WidgetTester tester) async {
      when(() => weatherCubit.state)
          .thenReturn(WeatherState(status: WeatherStatus.success));
      when(() => weatherCubit.fetchWeather(any())).thenAnswer((_) async {});
      await tester.pumpWidget(
        BlocProvider<WeatherCubit>.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherView()),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Toronto');
      await tester.tap(find.byKey(const Key('searchPage_search_iconButton')));
      await tester.pumpAndSettle();
      verify(() => weatherCubit.fetchWeather('Toronto')).called(1);
    });
  });
}
