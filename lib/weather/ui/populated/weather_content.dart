import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/ui/populated/weather_content_default.dart';
import 'package:weather_fit/weather/ui/populated/weather_content_extra_small.dart';

class WeatherContent extends StatefulWidget {
  const WeatherContent({
    required this.weather,
    required this.child,
    required this.onRefresh,
    super.key,
  });

  final Weather weather;
  final Widget child;
  final RefreshCallback onRefresh;

  @override
  State<WeatherContent> createState() => _WeatherContentState();
}

class _WeatherContentState extends State<WeatherContent> {
  @override
  Widget build(BuildContext context) {
    final Weather weather = widget.weather;
    return context.isExtraSmallScreen
        ? WeatherContentExtraSmall(
            onRefresh: widget.onRefresh,
            listenSettingsStateWhen: _shouldRebuildOnLanguageChange,
            settingsStateListener: _settingsStateListener,
            child: widget.child,
          )
        : WeatherContentDefault(
            weather: weather,
            onRefresh: widget.onRefresh,
            listenSettingsStateWhen: _shouldRebuildOnLanguageChange,
            settingsStateListener: _settingsStateListener,
            child: widget.child,
          );
  }

  void _settingsStateListener(BuildContext _, SettingsState _) {
    setState(() {});
  }

  bool _shouldRebuildOnLanguageChange(
    SettingsState previousState,
    SettingsState currentState,
  ) {
    final String languageCode = LocalizedApp.of(
      context,
    ).delegate.currentLocale.languageCode;

    final Language currentLanguage = Language.fromIsoLanguageCode(languageCode);
    return previousState.language != currentState.language ||
        currentLanguage != currentState.language;
  }
}
