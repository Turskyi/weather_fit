import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/res/extensions/weather_code_extension.dart';
import 'package:weather_repository/weather_repository.dart';

class ForecastItemWidget extends StatelessWidget {
  const ForecastItemWidget({
    required this.item,
    required this.isCelsius,
    super.key,
  });

  final ForecastItemDomain item;
  final bool isCelsius;

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

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final double temperatureValue = item.temperature;
    final double temperature = isCelsius
        ? temperatureValue
        : temperatureValue.toFahrenheit();
    final String unit = isCelsius ? 'C' : 'F';

    final DateTime itemDate = DateTime.parse(item.time);
    final String day = _getDay(itemDate);
    final String time = DateFormat.j().format(itemDate);
    final String temp = '${temperature.round()}°$unit';
    final String emoji = item.weatherCode.toWeatherEmoji;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          day,
          style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(time, style: textTheme.labelMedium),
        const SizedBox(height: 8),
        Text(emoji, style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(temp, style: textTheme.labelMedium),
      ],
    );
  }
}
