import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
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
        return previousState.language != currentState.language;
      },
      listener: (BuildContext _, SettingsState __) {
        setState(() {});
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('🏙️', style: TextStyle(fontSize: 64)),
          Text(
            translate('explore_weather_prompt'),
            style: theme.textTheme.headlineMedium,
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
