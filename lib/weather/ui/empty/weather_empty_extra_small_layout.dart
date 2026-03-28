import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';

class WeatherEmptyExtraSmallLayout extends StatelessWidget {
  const WeatherEmptyExtraSmallLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        const SizedBox(height: 40.0),
        Text(
          '🏙️',
          style: TextStyle(fontSize: textTheme.headlineLarge?.fontSize),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            translate('weather.empty_search_prompt'),
            style: textTheme.labelMedium?.copyWith(
              color: context.watchForegroundColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
