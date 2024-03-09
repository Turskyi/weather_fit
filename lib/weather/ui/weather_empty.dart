import 'package:flutter/material.dart';

class WeatherEmpty extends StatelessWidget {
  const WeatherEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text('🏙️', style: TextStyle(fontSize: 64)),
        Text(
          'Let\'s explore the weather! ',
          style: theme.textTheme.headlineMedium,
        ),
        Text(
          'Tap here to search for a city.',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
