import 'package:flutter/material.dart';
import 'package:weather_fit/about/about_page.dart';
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
      return WeatherPage(languageIsoCode: languageIsoCode);
    },
    AppRoute.search.path: (BuildContext _) => const SearchPage(),
    AppRoute.support.path: (BuildContext _) {
      return SupportPage(languageIsoCode: languageIsoCode);
    },
    AppRoute.settings.path: (BuildContext _) => const SettingsPage(),
    AppRoute.about.path: (BuildContext _) {
      return AboutPage(languageIsoCode: languageIsoCode);
    },
    AppRoute.privacyPolicyAndroid.path: (BuildContext _) {
      return PrivacyPolicyAndroidPage(languageIsoCode: languageIsoCode);
    },
    AppRoute.privacyPolicy.path: (BuildContext _) {
      return PrivacyPolicyPage(languageIsoCode: languageIsoCode);
    },
  };
}
