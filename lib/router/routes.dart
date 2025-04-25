import 'package:flutter/material.dart';
import 'package:weather_fit/privacy_policy/privacy_policy_android_page.dart';
import 'package:weather_fit/privacy_policy/privacy_policy_page.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/search/ui/search_page.dart';
import 'package:weather_fit/settings/ui/settings_page.dart';
import 'package:weather_fit/support/support_page.dart';
import 'package:weather_fit/weather/ui/weather_page.dart';

Map<String, WidgetBuilder> routeMap = <String, WidgetBuilder>{
  AppRoute.weather.path: (_) => const WeatherPage(),
  AppRoute.search.path: (_) => const SearchPage(),
  AppRoute.support.path: (_) => const SupportPage(),
  AppRoute.settings.path: (_) => const SettingsPage(),
  AppRoute.privacyPolicyAndroid.path: (_) => const PrivacyPolicyAndroidPage(),
  AppRoute.privacyPolicy.path: (_) => const PrivacyPolicyPage(),
};
