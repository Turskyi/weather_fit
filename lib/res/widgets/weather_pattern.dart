import 'package:flutter/material.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherPattern extends StatelessWidget {
  const WeatherPattern({
    required this.condition,
    required this.isNight,
    super.key,
  });

  final WeatherCondition condition;
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    final double fontSize =
        Theme.of(context).textTheme.displayLarge?.fontSize ?? 57;

    final String emoji = _getEmoji(condition, isNight);

    return IgnorePointer(
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: fontSize * 2,
          mainAxisSpacing: 40,
          crossAxisSpacing: 40,
        ),
        // Large number to ensure screen is filled
        itemCount: 200,
        itemBuilder: (BuildContext context, int index) {
          final double opacity = isNight ? 0.07 : 0.22;
          return Center(
            child: Transform.rotate(
              angle: index % 2 == 0 ? 0.2 : -0.2,
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: opacity),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getEmoji(WeatherCondition condition, bool isNight) {
    switch (condition) {
      case WeatherCondition.clear:
        return isNight ? '🌕' : '☀️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.cloudy:
        return isNight ? '☁️' : '🌥️';
      case WeatherCondition.snowy:
        return '🌨️';
      case WeatherCondition.unknown:
        return '';
    }
  }
}
