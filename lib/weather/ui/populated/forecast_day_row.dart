import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/weather/ui/populated/temperature_range_bar.dart';
import 'package:weather_repository/weather_repository.dart';

class ForecastDayRow extends StatelessWidget {
  const ForecastDayRow({
    required this.day,
    required this.temperatureUnits,
    required this.isExtraSmall,
    required this.globalMin,
    required this.globalMax,
    super.key,
  });

  final ForecastDayDomain day;
  final TemperatureUnits temperatureUnits;
  final bool isExtraSmall;
  final double globalMin;
  final double globalMax;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime dateTime = DateTime.parse(day.time);
    final String dayName = DateFormat.E(
      Localizations.localeOf(context).languageCode,
    ).format(dateTime);

    final double minTemp = temperatureUnits.isFahrenheit
        ? day.minTemp.toFahrenheit()
        : day.minTemp;
    final double maxTemp = temperatureUnits.isFahrenheit
        ? day.maxTemp.toFahrenheit()
        : day.maxTemp;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExtraSmall ? 4 : 16,
        vertical: isExtraSmall ? 6 : 12,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: isExtraSmall ? 26 : 44,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                dayName,
                style:
                    (isExtraSmall ? textTheme.labelSmall : textTheme.bodyLarge)
                        ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: isExtraSmall ? 2 : 8),
          Text(
            day.toCondition().toEmoji,
            style: TextStyle(fontSize: isExtraSmall ? 16 : 24),
          ),
          const Spacer(),
          SizedBox(
            width: isExtraSmall ? 22 : 40,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '${minTemp.round()}°',
                textAlign: TextAlign.right,
                style:
                    (isExtraSmall ? textTheme.labelSmall : textTheme.bodyLarge)
                        ?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
              ),
            ),
          ),
          SizedBox(width: isExtraSmall ? 2 : 4),
          Expanded(
            flex: isExtraSmall ? 2 : 4,
            child: TemperatureRangeBar(
              min: day.minTemp,
              max: day.maxTemp,
              globalMin: globalMin,
              globalMax: globalMax,
            ),
          ),
          SizedBox(width: isExtraSmall ? 2 : 4),
          SizedBox(
            width: isExtraSmall ? 22 : 40,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${maxTemp.round()}°',
                textAlign: TextAlign.left,
                style:
                    (isExtraSmall ? textTheme.labelSmall : textTheme.bodyLarge)
                        ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
