import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';

class WeatherEmpty extends StatefulWidget {
  const WeatherEmpty({super.key});

  @override
  State<WeatherEmpty> createState() => _WeatherEmptyState();
}

class _WeatherEmptyState extends State<WeatherEmpty> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocListener<SettingsBloc, SettingsState>(
      // `listenWhen` is crucial for performance:
      // Only call the listener if the language property has actually changed.
      listenWhen: (SettingsState previousState, SettingsState currentState) {
        final String languageCode = LocalizedApp.of(
          context,
        ).delegate.currentLocale.languageCode;

        final Language currentLanguage = Language.fromIsoLanguageCode(
          languageCode,
        );
        return previousState.language != currentState.language ||
            currentLanguage != currentState.language;
      },
      listener: (BuildContext _, SettingsState _) {
        setState(() {});
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: <Widget>[
          Text(
            '🏙️',
            style: TextStyle(fontSize: theme.textTheme.displayLarge?.fontSize),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              translate('explore_weather_prompt'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
          ),
          Text(
            translate('weather.empty_search_prompt'),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
