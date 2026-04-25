import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/populated/wear_forecast_row.dart';
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
                  WearForecastRow(
                    item: forecast[index],
                    temperatureUnits: state.temperatureUnits,
                  ),
                  if (index < forecast.length - 1)
                    Divider(
                      height: 12,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.12,
                      ),
                    ),
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
