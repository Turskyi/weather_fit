import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_fit/app/deep_link_navigation_logic.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;

class MockNavigatorState extends Mock implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class FakeRoute extends Fake implements Route<Object?> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('isWeatherWidgetDeepLink', () {
    test('returns true for weather widget URI', () {
      final Uri uri = Uri(
        scheme: constants.kWeatherFitScheme,
        host: constants.kWeatherFitHost,
      );

      final bool result = isWeatherWidgetDeepLink(uri);

      expect(result, isTrue);
    });

    test('returns false for null URI', () {
      final bool result = isWeatherWidgetDeepLink(null);

      expect(result, isFalse);
    });

    test('returns false for non-matching URI', () {
      final Uri uri = Uri(scheme: 'https', host: 'example.com');

      final bool result = isWeatherWidgetDeepLink(uri);

      expect(result, isFalse);
    });
  });

  group('navigateToWeatherRoot', () {
    test('replaces stack with weather route', () {
      final MockNavigatorState navigatorState = MockNavigatorState();
      when(
        () => navigatorState.pushNamedAndRemoveUntil(any(), any()),
      ).thenAnswer((_) async => null);

      navigateToWeatherRoot(navigatorState);

      verify(
        () => navigatorState.pushNamedAndRemoveUntil(
          constants.kWeatherRoute,
          any(),
        ),
      ).called(1);
    });

    test('does nothing for null navigator', () {
      navigateToWeatherRoot(null);

      expect(true, isTrue);
    });
  });
}
