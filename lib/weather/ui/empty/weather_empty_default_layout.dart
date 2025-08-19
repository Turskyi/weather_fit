import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class WeatherEmptyDefaultLayout extends StatelessWidget {
  const WeatherEmptyDefaultLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: <Widget>[
        Text(
          '🏙️',
          style: TextStyle(fontSize: textTheme.displayLarge?.fontSize),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            translate('explore_weather_prompt'),
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium,
          ),
        ),
        Text(
          translate('weather.empty_search_prompt'),
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
