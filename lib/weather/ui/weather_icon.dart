import 'package:flutter/material.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherIcon extends StatelessWidget {
  const WeatherIcon({super.key, required this.condition});

  static const double _iconSize = 75.0;

  final WeatherCondition condition;

  @override
  Widget build(BuildContext context) {
    return Text(
      condition.toEmoji,
      style: const TextStyle(fontSize: _iconSize),
    );
  }
}
