import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:weather_fit/entities/enums/weather_fetch_origin.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;
import 'package:weather_fit/services/device_type_service.dart';

/// Returns `true` when the current device is a Wear OS watch.
///
/// Uses [ui.PlatformDispatcher] so it works before any widget is built
/// (no [BuildContext] required).
bool get isWearDevice {
  if (nativeWearDevice) {
    return true;
  }

  final ui.FlutterView? view = ui.PlatformDispatcher.instance.implicitView;
  if (view == null) return false;
  final double shortest =
      view.physicalSize.shortestSide / view.devicePixelRatio;
  return shortest <= constants.kWearCompactLayoutSize;
}

extension ResponsiveChecks on BuildContext {
  /// The width of the screen.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// The height of the screen.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  double get shortestSide => MediaQuery.sizeOf(this).shortestSide;

  static const double _narrowScreenThreshold = 500.0;

  /// Returns `true` if the screen width is less than or equal to
  /// the shared Wear compact layout threshold.
  bool get isExtraSmallScreen =>
      isWearDevice || shortestSide <= constants.kWearCompactLayoutSize;

  bool get isNarrowScreen => screenWidth <= _narrowScreenThreshold;

  double get wearHorizontalPadding {
    if (!isExtraSmallScreen) {
      return 16.0;
    }

    final double proportionalPadding = shortestSide * 0.12;
    return proportionalPadding.clamp(14.0, 22.0);
  }

  double get wearBottomPadding {
    if (!isExtraSmallScreen) {
      return 24.0;
    }

    final double proportionalPadding = shortestSide * 0.1;
    return proportionalPadding.clamp(18.0, 28.0);
  }

  WeatherFetchOrigin get origin => isExtraSmallScreen
      ? WeatherFetchOrigin.wearable
      : WeatherFetchOrigin.defaultDevice;

  double get maxWidth => screenWidth > 600 ? 600 : double.infinity;

  /// The brightest colour available in the current theme — suitable for text
  /// and icons rendered on the Wear OS black scaffold background.
  Color get watchForegroundColor {
    final ColorScheme cs = Theme.of(this).colorScheme;
    return <Color>[
      cs.onSurface,
      cs.onInverseSurface,
      cs.inverseSurface,
      cs.onPrimary,
    ].reduce(
      (Color a, Color b) => b.computeLuminance() > a.computeLuminance() ? b : a,
    );
  }
}
