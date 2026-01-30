import 'package:flutter/material.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherIcon extends StatelessWidget {
  const WeatherIcon({required this.condition, super.key});

  static const double _iconSize = 75.0;

  final WeatherCondition condition;

  @override
  Widget build(BuildContext context) {
    return Text(
      condition.toEmoji,
      style: TextStyle(fontSize: context.isExtraSmallScreen ? 32 : _iconSize),
    );
  }
}
