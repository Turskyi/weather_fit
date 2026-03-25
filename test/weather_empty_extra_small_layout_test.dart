import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/weather/ui/empty/weather_empty_extra_small_layout.dart';

import 'helpers/flutter_translate_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate localizationDelegate;

  setUpAll(() async {
    localizationDelegate = await setUpFlutterTranslateForTests();
  });

  testWidgets(
    'renders empty search prompt with theme-derived foreground color',
    (WidgetTester tester) async {
      final ColorScheme colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: colorScheme),
          localizationsDelegates: <LocalizationsDelegate<Object?>>[
            localizationDelegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: localizationDelegate.supportedLocales,
          locale: localizationDelegate.currentLocale,
          home: const Material(child: WeatherEmptyExtraSmallLayout()),
        ),
      );

      await tester.pumpAndSettle();

      final String promptText = 'Tap 🔍 to search for a city or country.';
      final Text promptWidget = tester.widget<Text>(find.text(promptText));

      final BuildContext context = tester.element(
        find.byType(WeatherEmptyExtraSmallLayout),
      );
      final ColorScheme scheme = Theme.of(context).colorScheme;
      final Color expected =
          <Color>[
            scheme.onSurface,
            scheme.onInverseSurface,
            scheme.inverseSurface,
            scheme.onPrimary,
          ].reduce(
            (Color a, Color b) =>
                b.computeLuminance() > a.computeLuminance() ? b : a,
          );

      expect(promptWidget.style?.color, expected);
    },
  );
}
