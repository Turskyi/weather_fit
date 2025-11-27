import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

import 'forecast_item.dart';

class DailyForecast extends StatelessWidget {
  const DailyForecast({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    translate('weather.daily_forecast_title'),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<WeatherBloc, WeatherState>(
                    builder: (BuildContext context, WeatherState state) {
                      final DailyForecastDomain? dailyForecast =
                          state.dailyForecast;
                      if (dailyForecast == null) {
                        return Center(
                          child: Text(translate('weather.loading_forecast')),
                        );
                      }
                      final List<ForecastItemDomain> forecastItems =
                          dailyForecast.forecast;

                      const List<int> desiredHours = <int>[8, 13, 19];
                      final List<ForecastItemDomain> forecast =
                          <ForecastItemDomain>[];
                      for (final int hour in desiredHours) {
                        try {
                          final ForecastItemDomain item = forecastItems
                              .firstWhere(
                                (ForecastItemDomain item) =>
                                    DateTime.parse(item.time).hour == hour,
                              );
                          forecast.add(item);
                        } catch (_) {
                          // Item not found for the desired hour, so we skip it.
                        }
                      }

                      if (forecast.isEmpty) {
                        return Center(
                          child: Text(
                            translate('weather.forecast_unavailable'),
                          ),
                        );
                      }

                      final bool isCelsius = state.isCelsius;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          for (final ForecastItemDomain item in forecast)
                            ForecastItem(item: item, isCelsius: isCelsius),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
