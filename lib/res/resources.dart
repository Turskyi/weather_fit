import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:weather_fit/res/values/app_durations.dart';
import 'package:weather_fit/res/values/dimens.dart';

class Resources extends InheritedWidget {
  const Resources({
    required super.child,
    super.key,
    this.dimens = const Dimens(),
    this.durations = const AppDurations(),
  });

  final Dimens dimens;
  final AppDurations durations;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  /// Returns the nearest [Resources] widget in the ancestor tree of [context].
  ///
  /// This method asserts that the result is not `null`, as we expect the
  /// [Resources] widget to be always present in the [EthicalScannerApp].
  /// If the [Resources] widget is not found, a runtime exception is thrown.
  static Resources of(BuildContext context) {
    Resources? resources =
        context.dependOnInheritedWidgetOfExactType<Resources>();
    if (resources != null) {
      return resources;
    } else {
      throw Exception(
        'You should wrap your app with `Resources InheritedWidget` and pass '
        'the root app widget to the child parameter.',
      );
    }
  }
}
