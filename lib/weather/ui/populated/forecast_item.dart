import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/res/extensions/weather_code_extension.dart';
import 'package:weather_repository/weather_repository.dart';

class ForecastItem extends StatelessWidget {
  const ForecastItem({required this.item, required this.isCelsius, super.key});

  final ForecastItemDomain item;
  final bool isCelsius;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final double temperatureValue = item.temperature;
    final double temperature = isCelsius
        ? temperatureValue
        : temperatureValue.toFahrenheit();
    final String unit = isCelsius ? 'C' : 'F';

    final String time = DateFormat.j().format(DateTime.parse(item.time));
    final String temp = '${temperature.round()}°$unit';
    final String emoji = item.weatherCode.toWeatherEmoji;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(time, style: textTheme.labelMedium),
        const SizedBox(height: 8),
        Text(emoji, style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(temp, style: textTheme.labelMedium),
      ],
    );
  }
}
