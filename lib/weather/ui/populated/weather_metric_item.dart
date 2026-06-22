import 'package:flutter/material.dart';
import 'package:weather_fit/weather/ui/populated/weather_details_container.dart';
import 'package:weather_fit/weather/ui/populated/weather_metric_data.dart';

class WeatherMetricItem extends StatelessWidget {
  const WeatherMetricItem({required this.metric, super.key});

  final WeatherMetricData metric;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return WeatherDetailsContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          Icon(
            metric.icon,
            size: 20,
            color: colors.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  metric.label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  metric.value,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
