import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/weather/ui/populated/weather_details_container.dart';

class WeatherFeelsLikeCard extends StatelessWidget {
  const WeatherFeelsLikeCard({required this.weather, super.key});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final String? feelsLike = weather.formattedFeelsLike;
    if (feelsLike == null) return const SizedBox.shrink();

    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return WeatherDetailsContainer(
      child: Column(
        children: <Widget>[
          Text(
            translate('weather.feels_like'),
            style: textTheme.labelLarge?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            feelsLike,
            style: textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
