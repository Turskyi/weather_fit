import 'package:flutter/material.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/weather/ui/populated/weather_details_container.dart';
import 'package:weather_fit/weather/ui/populated/weather_metric_data.dart';

class WeatherMetricItem extends StatelessWidget {
  const WeatherMetricItem({required this.metric, super.key});

  final WeatherMetricData metric;

  @override
  Widget build(BuildContext context) {
    final bool isExtraSmall = context.isExtraSmallScreen;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return WeatherDetailsContainer(
      padding: EdgeInsets.all(isExtraSmall ? 8 : 12),
      child: Row(
        children: <Widget>[
          Icon(
            metric.icon,
            size: isExtraSmall ? 16 : 20,
            color: colors.onSurface.withValues(alpha: 0.7),
          ),
          SizedBox(width: isExtraSmall ? 6 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  metric.label,
                  style:
                      (isExtraSmall
                              ? textTheme.labelSmall?.copyWith(fontSize: 10)
                              : textTheme.labelSmall)
                          ?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    metric.value,
                    style:
                        (isExtraSmall
                                ? textTheme.titleSmall
                                : textTheme.titleMedium)
                            ?.copyWith(fontWeight: FontWeight.bold),
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
