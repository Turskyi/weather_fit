import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/ui/empty/weather_empty_default_layout.dart';
import 'package:weather_fit/weather/ui/empty/weather_empty_extra_small_layout.dart';

class WeatherEmpty extends StatefulWidget {
  const WeatherEmpty({super.key});

  @override
  State<WeatherEmpty> createState() => _WeatherEmptyState();
}

class _WeatherEmptyState extends State<WeatherEmpty> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    // 192.0 is the size of Kate's Pixel Watch 2.
    final bool isExtraSmallScreen = screenWidth <= 200.0;
    return BlocListener<SettingsBloc, SettingsState>(
      // `listenWhen` is crucial for performance:
      // Only call the listener if the language property has actually changed.
      listenWhen: _shouldRebuildOnLanguageChange,
      listener: _settingsStateListener,
      child: isExtraSmallScreen
          ? WeatherEmptyExtraSmallLayout(key: widget.key)
          : WeatherEmptyDefaultLayout(key: widget.key),
    );
  }

  /// [_shouldRebuildOnLanguageChange] is crucial for performance:
  /// Only call the listener if the language property has actually changed.
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

  void _settingsStateListener(BuildContext _, SettingsState _) {
    setState(() {});
  }
}
