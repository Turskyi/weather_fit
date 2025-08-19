import 'package:flutter/material.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/weather/ui/populated/weather_content.dart';

class WeatherPopulated extends StatelessWidget {
  const WeatherPopulated({
    required this.weather,
    required this.onRefresh,
    this.child = const SizedBox(),
    super.key,
  });

  final Weather weather;
  final RefreshCallback onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Background(),
        RefreshIndicator(
          onRefresh: onRefresh,
          child: WeatherContent(
            weather: weather,
            onRefresh: onRefresh,
            child: child,
          ),
        ),
      ],
    );
  }
}
