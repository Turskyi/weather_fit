import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:weather_fit/entities/enums/weather_fetch_origin.dart';

/// Returns `true` when the current device is a Wear OS watch.
///
/// Uses [ui.PlatformDispatcher] so it works before any widget is built
/// (no [BuildContext] required).
bool get isWearDevice {
  final ui.FlutterView? view = ui.PlatformDispatcher.instance.implicitView;
  if (view == null) return false;
  final double shortest =
      view.physicalSize.shortestSide / view.devicePixelRatio;
  return shortest <= ResponsiveChecks._extraSmallScreenThreshold;
}

extension ResponsiveChecks on BuildContext {
  /// The width of the screen.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// The height of the screen.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  double get shortestSide => MediaQuery.sizeOf(this).shortestSide;

  /// Threshold for defining an "extra small" screen, e.g., for a watch.
  /// Based on the size of a Pixel Watch 2 (192.0 logical pixels).
  static const double _extraSmallScreenThreshold = 200.0;
  static const double _narrowScreenThreshold = 500.0;

  /// Returns `true` if the screen width is less than or equal to
  /// the [_extraSmallScreenThreshold].
  bool get isExtraSmallScreen => shortestSide <= _extraSmallScreenThreshold;

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
}
