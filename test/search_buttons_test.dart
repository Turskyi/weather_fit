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
}
