import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/weather/ui/populated/weather_metric_data.dart';
import 'package:weather_fit/weather/ui/populated/weather_metric_item.dart';

class WeatherAdditionalMetricsGrid extends StatelessWidget {
  const WeatherAdditionalMetricsGrid({required this.weather, super.key});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final List<WeatherMetricData> metrics = <WeatherMetricData>[
      if (weather.humidity != null)
        WeatherMetricData(
          label: translate('weather.humidity'),
          value: '${weather.humidity!.round()}%',
          icon: Icons.water_drop_outlined,
        ),
      if (weather.windSpeed != null)
        WeatherMetricData(
          label: translate('weather.wind_speed'),
          value: '${weather.windSpeed!.round()} km/h',
          icon: Icons.air,
        ),
      if (weather.uvIndex != null)
        WeatherMetricData(
          label: translate('weather.uv_index'),
          value: weather.uvIndex!.toStringAsFixed(1),
          icon: Icons.wb_sunny_outlined,
        ),
      if (weather.visibility != null)
        WeatherMetricData(
          label: translate('weather.visibility'),
          value: '${(weather.visibility! / 1000).toStringAsFixed(1)} km',
          icon: Icons.visibility_outlined,
        ),
      if (weather.cloudCover != null)
        WeatherMetricData(
          label: translate('weather.cloud_cover'),
          value: '${weather.cloudCover!.round()}%',
          icon: Icons.cloud_outlined,
        ),
      if (weather.pressure != null)
        WeatherMetricData(
          label: translate('weather.pressure'),
          value: '${weather.pressure!.round()} hPa',
          icon: Icons.speed,
        ),
      if (weather.dewPoint != null)
        WeatherMetricData(
          label: translate('weather.dew_point'),
          value: '${weather.dewPoint!.round()}°',
          icon: Icons.device_thermostat_outlined,
        ),
    ];

    if (metrics.isEmpty) return const SizedBox.shrink();

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2,
        ),
        itemCount: metrics.length,
        itemBuilder: (BuildContext context, int index) {
          final WeatherMetricData metric = metrics[index];
          return WeatherMetricItem(metric: metric);
        },
      ),
    );
  }
}
