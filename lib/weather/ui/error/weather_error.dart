import 'package:flutter/material.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/weather/ui/error/weather_error_default.dart';
import 'package:weather_fit/weather/ui/error/weather_error_extra_small.dart';

class WeatherError extends StatelessWidget {
  const WeatherError({
    required this.onReportPressed,
    required this.message,
    super.key,
  });

  final String message;
  final VoidCallback onReportPressed;

  @override
  Widget build(BuildContext context) {
    return context.isExtraSmallScreen
        ? WeatherErrorExtraSmall(
            message: message,
            onReportPressed: onReportPressed,
          )
        : WeatherErrorDefault(message: message);
  }
}
