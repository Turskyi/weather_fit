import 'package:flutter/material.dart';
import 'package:weather_fit/about/about_page.dart';
import 'package:weather_fit/error/unable_to_connect.dart';
import 'package:weather_fit/privacy_policy/privacy_policy_android_page.dart';
import 'package:weather_fit/privacy_policy/privacy_policy_page.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/search/ui/search_page.dart';
import 'package:weather_fit/settings/ui/settings_page.dart';
import 'package:weather_fit/support/support_page.dart';
import 'package:weather_fit/weather/ui/weather_page.dart';

Map<String, WidgetBuilder> getRouteMap(String languageIsoCode) {
  return <String, WidgetBuilder>{
    AppRoute.weather.path: (BuildContext _) {
      return const WeatherPage();
    },
    AppRoute.search.path: (BuildContext context) {
      return SearchPage(languageIsoCode: languageIsoCode);
    },
    AppRoute.settings.path: (BuildContext _) {
      return const SettingsPage();
    },
    AppRoute.support.path: (BuildContext _) {
      return SupportPage(languageIsoCode: languageIsoCode);
    },
    AppRoute.about.path: (BuildContext _) {
      return AboutPage(languageIsoCode: languageIsoCode);
    },
    AppRoute.privacyPolicyAndroid.path: (BuildContext _) {
      return PrivacyPolicyAndroidPage(languageIsoCode: languageIsoCode);
    },
    AppRoute.privacyPolicy.path: (BuildContext _) {
      return PrivacyPolicyPage(languageIsoCode: languageIsoCode);
    },
    AppRoute.unableToConnect.path: (BuildContext _) {
      return const UnableToConnect();
    },
  };
}
