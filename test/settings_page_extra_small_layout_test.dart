import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/settings/ui/widgets/settings_page_extra_small_layout.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

import 'helpers/flutter_translate_test_utils.dart';
import 'helpers/mocks/mock_blocs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate localizationDelegate;
  late MockSettingsBloc settingsBloc;
  late MockWeatherBloc weatherBloc;

  setUpAll(() async {
    localizationDelegate = await setUpFlutterTranslateForTests();
  });

  setUp(() {
    settingsBloc = MockSettingsBloc();
    weatherBloc = MockWeatherBloc();

    final SettingsState settingsState = const SettingsInitial(
      language: Language.en,
    );
    final WeatherState weatherState = WeatherInitial(
      locale: 'en',
      dailyForecast: const DailyForecastDomain(
        forecast: <ForecastItemDomain>[],
      ),
      date: DateTime(2026),
    );

    when(() => settingsBloc.state).thenReturn(settingsState);
    when(() => weatherBloc.state).thenReturn(weatherState);
    whenListen(
      settingsBloc,
      Stream<SettingsState>.value(settingsState),
      initialState: settingsState,
    );
    whenListen(
      weatherBloc,
      Stream<WeatherState>.value(weatherState),
      initialState: weatherState,
    );
  });

  testWidgets('does not render pin widget card', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<SettingsBloc>.value(value: settingsBloc),
          BlocProvider<WeatherBloc>.value(value: weatherBloc),
        ],
        child: prepareWidgetForTesting(
          SettingsPageExtraSmallLayout(
            rebuildSettingsWhen: (_, _) => false,
            onLanguageChanged: (_) {},
            onDayStartHourChanged: (_) {},
            onNightStartHourChanged: (_) {},
            rebuildUnitsWhen: (_, _) => false,
            onUnitsChanged: (_) {},
            onAboutTap: () {},
            onPrivacyTap: () {},
            onFeedbackTap: () {},
            onSupportTap: () {},
            onPinWidgetTap: () {},
            onSearchPressed: () {},
          ),
          localizationDelegate,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.push_pin_outlined), findsNothing);
  });
}
