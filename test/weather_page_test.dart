import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_fit/data/repositories/ai_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/router/routes.dart' as routes;
import 'package:weather_fit/search/search_page.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/weather.dart';
import 'package:weather_fit/weather/ui/weather_page.dart';
import 'package:weather_repository/weather_repository.dart';

import 'helpers/hydrated_bloc.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockAiRepository extends Mock implements AiRepository {}

class MockThemeCubit extends MockCubit<Color> implements ThemeCubit {}

class MockWeatherBloc extends MockBloc<WeatherEvent, WeatherState>
    implements WeatherBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

const String _countryCode = 'gb';
const String _city = 'London';

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
          child: BlocProvider<WeatherBloc>(
            create: (_) => WeatherBloc(weatherRepository, aiRepository),
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
      lastUpdatedDateTime: DateTime(2020),
      city: _city,
      temperatureUnits: TemperatureUnits.celsius,
      countryCode: _countryCode,
    );
    late WeatherBloc weatherBloc;

    setUp(() {
      weatherBloc = MockWeatherBloc();
    });

    testWidgets('renders WeatherLoading for WeatherStatus.initial',
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

    testWidgets('renders WeatherLoading for WeatherStatus.loading',
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

    testWidgets('navigates to SearchPage when search button is tapped',
        (WidgetTester tester) async {
      when(() => weatherBloc.state).thenReturn(
        const WeatherLoadingState(),
      );
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: BlocProvider<WeatherBloc>.value(
            value: weatherBloc,
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

    testWidgets('triggers fetch on search pop', (WidgetTester tester) async {
      when(() => weatherBloc.state).thenReturn(
        WeatherSuccess(weather: weather.copyWith(countryCode: _countryCode)),
      );
      when(() => weatherBloc.add(const FetchWeather(city: 'Toronto')))
          .thenAnswer((_) async {});
      await tester.pumpWidget(
        RepositoryProvider<WeatherRepository>.value(
          value: weatherRepository,
          child: BlocProvider<WeatherBloc>.value(
            value: weatherBloc,
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
      verifyNever(() => weatherBloc.add(const FetchWeather(city: 'Toronto')))
          .called(0);
    });
  });
}
