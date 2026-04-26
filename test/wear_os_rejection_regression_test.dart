import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_fit/entities/models/quick_city_suggestion.dart';
import 'package:weather_fit/res/widgets/wear_position_indicator.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/search/ui/widgets/search_layout_extra_small.dart';

import 'helpers/flutter_translate_test_utils.dart';

class MockSearchBloc extends Mock implements SearchBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationDelegate localizationDelegate;
  late MockSearchBloc mockSearchBloc;

  setUpAll(() async {
    localizationDelegate = await setUpFlutterTranslateForTests();
    registerFallbackValue(const SearchLocation(''));
  });

  setUp(() {
    mockSearchBloc = MockSearchBloc();
    when(() => mockSearchBloc.state).thenReturn(
      const SearchInitial(quickCitiesSuggestions: <QuickCitySuggestion>[]),
    );
    when(
      () => mockSearchBloc.stream,
    ).thenAnswer((_) => const Stream<SearchState>.empty());
  });

  Widget buildSearchLayout(
    TextEditingController controller,
    WidgetTester tester,
  ) {
    // Set a small circular-like screen size to simulate Wear OS
    // and trigger isExtraSmallScreen layout.
    tester.view.physicalSize = const Size(220, 220);
    tester.view.devicePixelRatio = 1.0;

    return BlocProvider<SearchBloc>.value(
      value: mockSearchBloc,
      child: prepareWidgetForTesting(
        SearchPageExtraSmallLayout(
          textEditingController: controller,
          searchStateListener: (BuildContext context, SearchState state) {},
        ),
        localizationDelegate,
      ),
    );
  }

  group('Wear OS Regression Tests (Google Play Rejection Fixes)', () {
    testWidgets('Search input area MUST be tappable and localized to trigger '
        'native input', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();
      await tester.pumpWidget(buildSearchLayout(controller, tester));

      // We use pump() instead of pumpAndSettle() because there is a pending
      // timer from the auto-open logic in initState.
      await tester.pump();

      // Regression Fix 1 & 4: Tappable container with search icon
      // We find the InkWell that wraps the search box.
      final Finder searchBoxFinder = find.byWidgetPredicate(
        (Widget widget) =>
            widget is InkWell &&
            widget.child is Container &&
            (widget.child as Container).child is Row,
      );
      expect(searchBoxFinder, findsOneWidget);

      final Finder searchIconFinder = find.byIcon(Icons.search);
      expect(searchIconFinder, findsAtLeast(1));

      // Verify it contains the localized placeholder
      expect(find.text(translate('search.enter_location')), findsOneWidget);

      // Clean up pending timers
      await tester.pumpAndSettle(const Duration(seconds: 1));
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Search button MUST be enabled even for empty queries to prove '
        'functionality to reviewers', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController(text: '');
      await tester.pumpWidget(buildSearchLayout(controller, tester));
      await tester.pump();

      final Finder searchButtonFinder = find.byType(ElevatedButton);
      expect(searchButtonFinder, findsOneWidget);
      final ElevatedButton searchButton = tester.widget<ElevatedButton>(
        searchButtonFinder,
      );

      // Regression Fix 3: Button must be enabled even if query is empty
      expect(
        searchButton.onPressed,
        isNotNull,
        reason:
            'Search button must be enabled even for empty queries to satisfy '
            'Google Play functional description requirements',
      );

      // Clean up pending timers
      await tester.pumpAndSettle(const Duration(seconds: 1));
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets(
      'Search layout MUST include WearPositionIndicator for curved scrollbars',
      (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController();
        await tester.pumpWidget(buildSearchLayout(controller, tester));
        await tester.pump();

        expect(
          find.byType(WearPositionIndicator),
          findsOneWidget,
          reason:
              'WearPositionIndicator is required for curved scrollbars on '
              'circular Wear OS devices',
        );

        // Clean up pending timers
        await tester.pumpAndSettle(const Duration(seconds: 1));
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });
}
