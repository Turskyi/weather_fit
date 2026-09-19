import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/services/forecast_aggregation_service.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/populated/wear_forecast_row.dart';
import 'package:weather_repository/weather_repository.dart';

class WearForecastSection extends StatelessWidget {
  const WearForecastSection({super.key});

  static const Color _watchForecastCardBackground = Colors.black;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (BuildContext context, WeatherState state) {
        final List<ForecastItemDomain> forecast = _selectForecast(
          state.dailyForecast?.forecast ?? const <ForecastItemDomain>[],
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
          decoration: BoxDecoration(
            color: _watchForecastCardBackground,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (forecast.isEmpty)
                const SizedBox()
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
    return aggregateForecastItems(forecast);
  }
}
