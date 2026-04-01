import 'package:flutter/material.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;

bool isWeatherWidgetDeepLink(Uri? uri) {
  if (uri != null &&
      uri.scheme == constants.kWeatherFitScheme &&
      uri.host == constants.kWeatherFitHost) {
    return true;
  } else {
    return false;
  }
}

void navigateToWeatherRoot(NavigatorState? navigatorState) {
  if (navigatorState != null) {
    navigatorState.pushNamedAndRemoveUntil(
      constants.kWeatherRoute,
      (Route<Object?> route) => false,
    );
  }
}
