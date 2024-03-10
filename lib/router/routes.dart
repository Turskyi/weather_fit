import 'package:flutter/material.dart';
import 'package:weather_fit/privacy_policy/privacy_policy_android_page.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/search/search_page.dart';
import 'package:weather_fit/settings/settings_page.dart';
import 'package:weather_fit/weather/ui/weather_page.dart';

Map<String, WidgetBuilder> routeMap = <String, WidgetBuilder>{
  AppRoute.weather.path: (_) => const WeatherPage(),
  AppRoute.search.path: (_) => const SearchPage(),
  AppRoute.settings.path: (_) => const SettingsPage(),
  AppRoute.privacyPolicyAndroid.path: (_) => const PrivacyPolicyAndroidPage(),
};
