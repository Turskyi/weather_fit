import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/populated/weather_hourly_forecast_section.dart';
import 'package:weather_repository/weather_repository.dart';

import 'constants/dummy_constants.dart' as dummy_constants;
import 'helpers/flutter_translate_test_utils.dart';
import 'helpers/mocks/mock_blocs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate localizationDelegate;
  late MockWeatherBloc mockWeatherBloc;
  late MockSettingsBloc mockSettingsBloc;

  setUpAll(() async {
    localizationDelegate = await setUpFlutterTranslateForTests();
  });

  setUp(() {
    mockWeatherBloc = MockWeatherBloc();
    mockSettingsBloc = MockSettingsBloc();

    when(
      () => mockSettingsBloc.state,
    ).thenReturn(const SettingsInitial(language: Language.en));
  });

  Widget buildTestWidget({required Size screenSize, double textScaler = 1.0}) {
    final DateTime now = DateTime.now();
    final List<ForecastItemDomain> forecastItems =
        List<ForecastItemDomain>.generate(12, (int index) {
          final DateTime itemTime = now.add(Duration(hours: index + 1));
          return ForecastItemDomain(
            time: itemTime.toIso8601String(),
            temperature: 20.0 + index,
            weatherCode: 0,
          );
        });

    final DailyForecastDomain dailyForecast = DailyForecastDomain(
      forecast: forecastItems,
    );

    final WeatherSuccess weatherState = WeatherSuccess(
      date: now,
      locale: 'en',
      weather: dummy_constants.dummyWeather,
      dailyForecast: dailyForecast,
      outfitRecommendation: 'T-shirt and shorts',
    );

    when(() => mockWeatherBloc.state).thenReturn(weatherState);

    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      localizationsDelegates: <LocalizationsDelegate<Object?>>[
        localizationDelegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: localizationDelegate.supportedLocales,
      locale: localizationDelegate.currentLocale,
      home: MediaQuery(
        data: MediaQueryData(
          size: screenSize,
          textScaler: TextScaler.linear(textScaler),
        ),
        child: MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<WeatherBloc>.value(value: mockWeatherBloc),
            BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
          ],
          child: const Scaffold(
            body: SingleChildScrollView(child: WeatherHourlyForecastSection()),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'renders hourly forecast section without overflow on standard screens',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(screenSize: const Size(400, 800)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(WeatherHourlyForecastSection), findsOneWidget);
    },
  );

  testWidgets(
    'renders hourly forecast section without overflow on extra small screens',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(screenSize: const Size(200, 200)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(WeatherHourlyForecastSection), findsOneWidget);
    },
  );

  testWidgets(
    'renders hourly forecast section without overflow with 1.5x text scaling',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(screenSize: const Size(200, 200), textScaler: 1.5),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(WeatherHourlyForecastSection), findsOneWidget);
    },
  );
}
