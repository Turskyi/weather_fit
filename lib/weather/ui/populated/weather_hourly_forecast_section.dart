import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/populated/weather_details_container.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherHourlyForecastSection extends StatelessWidget {
  const WeatherHourlyForecastSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isExtraSmall = context.isExtraSmallScreen;
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
                style: isExtraSmall
                    ? textTheme.labelLarge
                    : textTheme.titleMedium,
              ),
            ),
            WeatherDetailsContainer(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: isExtraSmall ? 80 : 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: isExtraSmall ? 8 : 16,
                  ),
                  itemCount: nextHours.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ForecastItemDomain item = nextHours[index];
                    final DateTime time = DateTime.parse(item.time);
                    final String hour = DateFormat.Hm(
                      context.read<SettingsBloc>().state.locale,
                    ).format(time);

                    final double tempValue = state.temperatureUnits.isFahrenheit
                        ? item.temperature.toFahrenheit()
                        : item.temperature;

                    return Padding(
                      padding: EdgeInsets.only(
                        right: isExtraSmall ? 16.0 : 24.0,
                        top: isExtraSmall ? 8 : 12,
                        bottom: isExtraSmall ? 8 : 12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            hour,
                            style:
                                (isExtraSmall
                                        ? textTheme.labelSmall
                                        : textTheme.bodySmall)
                                    ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: isExtraSmall ? 2 : 4),
                          Text(
                            item.toCondition().toEmoji,
                            style: TextStyle(fontSize: isExtraSmall ? 16 : 20),
                          ),
                          SizedBox(height: isExtraSmall ? 2 : 4),
                          Text(
                            '${tempValue.round()}°',
                            style:
                                (isExtraSmall
                                        ? textTheme.labelMedium
                                        : textTheme.bodyMedium)
                                    ?.copyWith(fontWeight: FontWeight.bold),
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
