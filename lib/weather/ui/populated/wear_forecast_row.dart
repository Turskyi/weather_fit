import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/res/extensions/weather_code_extension.dart';
import 'package:weather_repository/weather_repository.dart';

class WearForecastRow extends StatelessWidget {
  const WearForecastRow({
    required this.item,
    required this.temperatureUnits,
    super.key,
  });

  final ForecastItemDomain item;
  final TemperatureUnits temperatureUnits;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color watchForegroundColor = context.watchForegroundColor;
    final DateTime itemDate = DateTime.parse(item.time);
    final double displayTemperature = temperatureUnits.isCelsius
        ? item.temperature
        : item.temperature.toFahrenheit();
    final String unit = temperatureUnits.unitSymbol;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Text(
            item.weatherCode.toWeatherEmoji,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _getDay(itemDate),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: watchForegroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _getTimeOfDay(itemDate.hour),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: watchForegroundColor,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${displayTemperature.round()}°$unit',
              style: theme.textTheme.labelMedium?.copyWith(
                color: watchForegroundColor,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
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
    } else if (itemDay == tomorrow) {
      return translate('weather.tomorrow');
    } else {
      return DateFormat.E().format(itemDate);
    }
  }

  String _getTimeOfDay(int hour) {
    String label;
    if (hour >= 0 && hour < 10) {
      label = translate('weather.time_of_day.morning');
    } else if (hour >= 10 && hour < 17) {
      label = translate('weather.time_of_day.day');
    } else {
      label = translate('weather.time_of_day.evening');
    }
    // Remove the hour range suffix e.g. " (0–10)" for extra small screen.
    return label.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
  }
}
