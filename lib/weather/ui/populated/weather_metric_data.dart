import 'package:flutter/widgets.dart';

class WeatherMetricData {
  WeatherMetricData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}
