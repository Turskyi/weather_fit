import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/weather/ui/widgets/weather_shimmer.dart';

class WeatherLoadingWidget extends StatelessWidget {
  const WeatherLoadingWidget({this.isShimmer = false, super.key});

  final bool isShimmer;

  @override
  Widget build(BuildContext context) {
    if (isShimmer) {
      return const WeatherShimmer();
    } else {
      final ThemeData theme = Theme.of(context);
      final ColorScheme colorScheme = theme.colorScheme;
      final TextStyle? textStyle = context.isExtraSmallScreen
          ? theme.textTheme.bodySmall
          : theme.textTheme.titleLarge;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.4),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Icon(Icons.cloud, size: 64, color: colorScheme.onPrimary),
          ),
          const SizedBox(height: 16.0),
          Text(
            translate('weather.loading_weather'),
            style: textStyle?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ],
      );
    }
  }
}
