import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class WeatherEmpty extends StatelessWidget {
  const WeatherEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
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
    );
  }
}
