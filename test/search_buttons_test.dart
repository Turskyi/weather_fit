import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/search/ui/widgets/search_buttons.dart';

import 'helpers/flutter_translate_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate localizationDelegate;

  setUpAll(() async {
    localizationDelegate = await setUpFlutterTranslateForTests();
  });

  Widget buildWidget({required bool showGpsButton}) {
    return prepareWidgetForTesting(
      SearchButtons(
        query: 'Kyiv',
        isLoading: false,
        onSearchSubmitted: (_) {},
        showGpsButton: showGpsButton,
      ),
      localizationDelegate,
    );
  }

  testWidgets('hides GPS button when showGpsButton is false', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildWidget(showGpsButton: false));
    await tester.pumpAndSettle();

    final Wrap wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.children.length, 1);
  });

  testWidgets('shows GPS button when showGpsButton is true', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildWidget(showGpsButton: true));
    await tester.pumpAndSettle();

    final Wrap wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.children.length, 2);
  });

  testWidgets('Search button is disabled when query is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      prepareWidgetForTesting(
        SearchButtons(
          query: '',
          isLoading: false,
          onSearchSubmitted: (_) {},
          showGpsButton: false,
        ),
        localizationDelegate,
      ),
    );

    await tester.pumpAndSettle();

    final Finder buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsOneWidget);

    final ElevatedButton button = tester.widget<ElevatedButton>(buttonFinder);
    expect(button.enabled, isFalse);
  });

  testWidgets('Search button is enabled when query is not empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      prepareWidgetForTesting(
        SearchButtons(
          query: 'London',
          isLoading: false,
          onSearchSubmitted: (_) {},
          showGpsButton: false,
        ),
        localizationDelegate,
      ),
    );

    await tester.pumpAndSettle();

    final Finder buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsOneWidget);

    final ElevatedButton button = tester.widget<ElevatedButton>(buttonFinder);
    expect(button.enabled, isTrue);
  });

  testWidgets('Search button is disabled when isLoading is true', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      prepareWidgetForTesting(
        SearchButtons(
          query: 'London',
          isLoading: true,
          onSearchSubmitted: (_) {},
          showGpsButton: false,
        ),
        localizationDelegate,
      ),
    );

    await tester.pump();

    final Finder buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsOneWidget);

    final ElevatedButton button = tester.widget<ElevatedButton>(buttonFinder);
    expect(button.enabled, isFalse);
  });

  testWidgets(
    'Search button is enabled even when query is empty on Extra Small Screen '
    '(Wear OS)',
    (WidgetTester tester) async {
      // Set a small size to simulate Wear OS
      tester.view.physicalSize = const Size(200, 200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        prepareWidgetForTesting(
          SearchButtons(
            query: '',
            isLoading: false,
            onSearchSubmitted: (_) {},
            showGpsButton: false,
          ),
          localizationDelegate,
        ),
      );

      await tester.pumpAndSettle();

      final Finder buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final ElevatedButton button = tester.widget<ElevatedButton>(buttonFinder);
      // It should be enabled on Wear OS to satisfy Play Store requirements
      expect(button.enabled, isTrue);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );
}
