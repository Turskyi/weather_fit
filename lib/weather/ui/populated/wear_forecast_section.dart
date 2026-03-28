import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/res/extensions/weather_code_extension.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class WearForecastSection extends StatelessWidget {
  const WearForecastSection({super.key});

  static const Color _watchForecastCardBackground = Colors.black;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color watchForegroundColor = context.watchForegroundColor;

    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (BuildContext context, WeatherState state) {
        final List<ForecastItemDomain> forecast = _selectForecast(
          state.dailyForecast?.forecast ?? const <ForecastItemDomain>[],
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _watchForecastCardBackground,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (forecast.isEmpty)
                Text(
                  translate('weather.forecast_unavailable'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: watchForegroundColor,
                  ),
                )
              else
                for (
                  int index = 0;
                  index < forecast.length;
                  index++
                ) ...<Widget>[
                  _WearForecastRow(
                    item: forecast[index],
                    isCelsius: state.isCelsius,
                  ),
                  if (index < forecast.length - 1)
                    const Divider(height: 12, color: Colors.white24),
                ],
            ],
          ),
        );
      },
    );
  }

  List<ForecastItemDomain> _selectForecast(List<ForecastItemDomain> forecast) {
    final DateTime now = DateTime.now();
    const List<int> preferredHours = <int>[8, 13, 19];

    final List<ForecastItemDomain> future = forecast.where((
      ForecastItemDomain item,
    ) {
      final DateTime? itemTime = DateTime.tryParse(item.time);
      return itemTime != null && itemTime.isAfter(now);
    }).toList();

    final List<ForecastItemDomain> preferred = future
        .where((ForecastItemDomain item) {
          final DateTime? itemTime = DateTime.tryParse(item.time);
          return itemTime != null && preferredHours.contains(itemTime.hour);
        })
        .take(3)
        .toList();

    if (preferred.isNotEmpty) {
      return preferred;
    }

    return future.take(3).toList();
  }
}

class _WearForecastRow extends StatelessWidget {
  const _WearForecastRow({required this.item, required this.isCelsius});

  final ForecastItemDomain item;
  final bool isCelsius;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color watchForegroundColor = context.watchForegroundColor;
    final DateTime itemDate = DateTime.parse(item.time);
    final double displayTemperature = isCelsius
        ? item.temperature
        : item.temperature.toFahrenheit();
    final String unit = isCelsius ? 'C' : 'F';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Text(
            item.weatherCode.toWeatherEmoji,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _getDay(itemDate),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: watchForegroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _getTimeOfDay(itemDate.hour),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: watchForegroundColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${displayTemperature.round()}°$unit',
            style: theme.textTheme.labelMedium?.copyWith(
              color: watchForegroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _getDay(DateTime itemDate) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    final DateTime itemDay = DateTime(
      itemDate.year,
      itemDate.month,
      itemDate.day,
    );

    if (itemDay == today) {
      return translate('weather.today');
    }
    if (itemDay == tomorrow) {
      return translate('weather.tomorrow');
    }
    return DateFormat.E().format(itemDate);
  }

  String _getTimeOfDay(int hour) {
    if (hour >= 5 && hour < 12) {
      return translate('weather.time_of_day.morning');
    }
    if (hour >= 12 && hour < 17) {
      return translate('weather.time_of_day.lunch');
    }
    return translate('weather.time_of_day.evening');
  }
}
