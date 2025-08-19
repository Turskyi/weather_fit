import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/settings/ui/settings_page_default_layout.dart';
import 'package:weather_fit/settings/ui/settings_page_extra_small_layout.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({required this.languageIsoCode, super.key});

  final String languageIsoCode;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return context.isExtraSmallScreen
        ? SettingsPageExtraSmallLayout(
            rebuildSettingsWhen: _isLanguageChanged,
            onLanguageChanged: _changeLanguage,
            rebuildUnitsWhen: _isUnitsChanged,
            onUnitsChanged: _changeUnits,
            onAboutTap: _navigateToAbout,
            onPrivacyTap: _navigateToPrivacy,
            onFeedbackTap: _handleFeedbackRequest,
            onSupportTap: _navigateToSupport,
            languageIsoCode: widget.languageIsoCode,
            onSearchPressed: _handleLocationSearchAndFetchWeather,
          )
        : SettingsPageDefaultLayout(
            rebuildSettingsWhen: _isLanguageChanged,
            onLanguageChanged: _changeLanguage,
            rebuildUnitsWhen: _isUnitsChanged,
            onUnitsChanged: _changeUnits,
            onAboutTap: _navigateToAbout,
            onPrivacyTap: _navigateToPrivacy,
            onFeedbackTap: _handleFeedbackRequest,
            onSupportTap: _navigateToSupport,
            languageIsoCode: widget.languageIsoCode,
          );
  }

  void _changeUnits(bool _) {
    context.read<WeatherBloc>().add(const ToggleUnits());
  }

  void _navigateToAbout() {
    Navigator.pushNamed(context, AppRoute.about.path);
  }

  void _navigateToSupport() {
    Navigator.pushNamed(context, AppRoute.support.path);
  }

  void _handleFeedbackRequest() {
    final SettingsState state = context.read<SettingsBloc>().state;
    context.read<SettingsBloc>().add(
      BugReportPressedEvent(state is SettingsError ? state.errorMessage : ''),
    );
  }

  void _navigateToPrivacy() {
    Navigator.pushNamed(
      context,
      defaultTargetPlatform == TargetPlatform.android
          ? AppRoute.privacyPolicyAndroid.path
          : AppRoute.privacyPolicy.path,
    );
  }

  bool _isUnitsChanged(WeatherState previous, WeatherState current) {
    return previous.weather.temperatureUnits !=
        current.weather.temperatureUnits;
  }

  bool _isLanguageChanged(SettingsState previous, SettingsState current) {
    return previous.language != current.language;
  }

  void _changeLanguage(bool isEnglish) {
    final Language newLanguage = isEnglish ? Language.en : Language.uk;
    changeLocale(context, newLanguage.isoLanguageCode)
    // The returned value is always `null`.
    .then((Object? _) {
      if (mounted) {
        context.read<SettingsBloc>().add(ChangeLanguageEvent(newLanguage));
      }
    });
  }

  Future<void> _handleLocationSearchAndFetchWeather() async {
    final Object? object = await Navigator.pushNamed<Object>(
      context,
      AppRoute.search.path,
    );

    if (mounted && object is Weather) {
      context.read<WeatherBloc>().add(
        GetOutfitEvent(weather: object, origin: context.origin),
      );
    } else {
      return;
    }
  }
}
