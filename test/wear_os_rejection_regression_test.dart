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
    testWidgets(
      'TextField MUST have interactive selection disabled and custom context '
      'menu suppressed to prevent tooltip clipping',
      (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController();
        await tester.pumpWidget(buildSearchLayout(controller, tester));
        await tester.pumpAndSettle();

        final Finder textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsOneWidget);

        final TextField textField = tester.widget<TextField>(textFieldFinder);

        // Regression Fix 1: enableInteractiveSelection MUST be false
        expect(
          textField.enableInteractiveSelection,
          isFalse,
          reason:
              'Interactive selection must be disabled to prevent "Paste" '
              'tooltip on Wear OS',
        );

        // Regression Fix 2: contextMenuBuilder MUST return an empty widget
        final BuildContext context = tester.element(textFieldFinder);
        final EditableTextState state = tester.state<EditableTextState>(
          find.descendant(
            of: textFieldFinder,
            matching: find.byType(EditableText),
          ),
        );

        final Widget menuWidget = textField.contextMenuBuilder!(context, state);
        expect(menuWidget, isA<SizedBox>());
        expect((menuWidget as SizedBox).width, 0.0);
        expect(menuWidget.height, 0.0);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );

    testWidgets('Search button MUST be enabled even for empty queries to prove '
        'functionality to reviewers', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController(text: '');
      await tester.pumpWidget(buildSearchLayout(controller, tester));
      await tester.pumpAndSettle();

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

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets(
      'Search layout MUST include WearPositionIndicator for curved scrollbars',
      (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController();
        await tester.pumpWidget(buildSearchLayout(controller, tester));
        await tester.pumpAndSettle();

        expect(
          find.byType(WearPositionIndicator),
          findsOneWidget,
          reason:
              'WearPositionIndicator is required for curved scrollbars on '
              'circular Wear OS devices',
        );

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );

    testWidgets('TextField MUST have a search icon to improve '
        'discoverability', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();
      await tester.pumpWidget(buildSearchLayout(controller, tester));
      await tester.pumpAndSettle();

      final Finder textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);
      final TextField textField = tester.widget<TextField>(textFieldFinder);

      expect(
        textField.decoration?.prefixIcon,
        isNotNull,
        reason:
            'Prefix search icon helps reviewers identify the field as a '
            'keyword search option',
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
