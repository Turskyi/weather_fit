import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherDetailsSection extends StatefulWidget {
  const WeatherDetailsSection({required this.weather, super.key});

  final Weather weather;

  @override
  State<WeatherDetailsSection> createState() => _WeatherDetailsSectionState();
}

class _WeatherDetailsSectionState extends State<WeatherDetailsSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext _) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: _toggleExpanded,
          child: Text(translate('weather.details_button')),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    children: <Widget>[
                      _FeelsLikeCard(weather: widget.weather),
                      const SizedBox(height: 16),
                      const _HourlyForecastSection(),
                      const SizedBox(height: 16),
                      _AdditionalMetricsGrid(weather: widget.weather),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _FeelsLikeCard extends StatelessWidget {
  const _FeelsLikeCard({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final String? feelsLike = weather.formattedFeelsLike;
    if (feelsLike == null) return const SizedBox.shrink();

    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return _DetailsContainer(
      child: Column(
        children: <Widget>[
          Text(
            translate('weather.feels_like'),
            style: textTheme.labelLarge?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            feelsLike,
            style: textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyForecastSection extends StatelessWidget {
  const _HourlyForecastSection();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (BuildContext context, WeatherState state) {
        final List<ForecastItemDomain> hourly =
            state.dailyForecast?.forecast ?? <ForecastItemDomain>[];
        if (hourly.isEmpty) return const SizedBox.shrink();

        // Get next 24 hours
        final DateTime now = DateTime.now();
        final List<ForecastItemDomain> nextHours = hourly.where((
          ForecastItemDomain item,
        ) {
          final DateTime? time = DateTime.tryParse(item.time);
          return time != null &&
              time.isAfter(now) &&
              time.isBefore(now.add(const Duration(hours: 25)));
        }).toList();

        if (nextHours.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                translate('weather.hourly_forecast_title'),
                style: textTheme.titleMedium,
              ),
            ),
            _DetailsContainer(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: nextHours.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ForecastItemDomain item = nextHours[index];
                    final DateTime time = DateTime.parse(item.time);
                    final String hour = DateFormat.Hm(
                      context.read<SettingsBloc>().state.locale,
                    ).format(time);

                    return Padding(
                      padding: const EdgeInsets.only(
                        right: 24.0,
                        top: 12,
                        bottom: 12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            hour,
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.toCondition().toEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.temperature.round()}°',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AdditionalMetricsGrid extends StatelessWidget {
  const _AdditionalMetricsGrid({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final List<_MetricData> metrics = <_MetricData>[
      if (weather.humidity != null)
        _MetricData(
          label: translate('weather.humidity'),
          value: '${weather.humidity!.round()}%',
          icon: Icons.water_drop_outlined,
        ),
      if (weather.windSpeed != null)
        _MetricData(
          label: translate('weather.wind_speed'),
          value: '${weather.windSpeed!.round()} km/h',
          icon: Icons.air,
        ),
      if (weather.uvIndex != null)
        _MetricData(
          label: translate('weather.uv_index'),
          value: weather.uvIndex!.toStringAsFixed(1),
          icon: Icons.wb_sunny_outlined,
        ),
      if (weather.visibility != null)
        _MetricData(
          label: translate('weather.visibility'),
          value: '${(weather.visibility! / 1000).toStringAsFixed(1)} km',
          icon: Icons.visibility_outlined,
        ),
      if (weather.cloudCover != null)
        _MetricData(
          label: translate('weather.cloud_cover'),
          value: '${weather.cloudCover!.round()}%',
          icon: Icons.cloud_outlined,
        ),
      if (weather.pressure != null)
        _MetricData(
          label: translate('weather.pressure'),
          value: '${weather.pressure!.round()} hPa',
          icon: Icons.speed,
        ),
      if (weather.dewPoint != null)
        _MetricData(
          label: translate('weather.dew_point'),
          value: '${weather.dewPoint!.round()}°',
          icon: Icons.device_thermostat_outlined,
        ),
    ];

    if (metrics.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
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
        final _MetricData metric = metrics[index];
        return _MetricItem(metric: metric);
      },
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.metric});

  final _MetricData metric;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return _DetailsContainer(
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

class _MetricData {
  _MetricData({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;
}

class _DetailsContainer extends StatelessWidget {
  const _DetailsContainer({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }
}
