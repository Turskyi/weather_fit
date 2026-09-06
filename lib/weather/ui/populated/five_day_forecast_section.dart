import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/weather/ui/populated/weather_details_container.dart';
import 'package:weather_repository/weather_repository.dart';

class FiveDayForecastSection extends StatelessWidget {
  const FiveDayForecastSection({
    required this.dailyForecast,
    required this.temperatureUnits,
    super.key,
  });

  final List<ForecastDayDomain> dailyForecast;
  final TemperatureUnits temperatureUnits;

  @override
  Widget build(BuildContext context) {
    if (dailyForecast.isEmpty) return const SizedBox.shrink();

    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isExtraSmall = context.isExtraSmallScreen;

    // Calculate global min/max for relative temperature bars.
    final double globalMin = dailyForecast.fold(
      dailyForecast.first.minTemp,
      (double min, ForecastDayDomain day) =>
          day.minTemp < min ? day.minTemp : min,
    );
    final double globalMax = dailyForecast.fold(
      dailyForecast.first.maxTemp,
      (double max, ForecastDayDomain day) =>
          day.maxTemp > max ? day.maxTemp : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.calendar_month_outlined,
                size: isExtraSmall ? 16 : 20,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                translate('weather.five_day_forecast_title'),
                style: isExtraSmall
                    ? textTheme.labelLarge
                    : textTheme.titleMedium,
              ),
            ],
          ),
        ),
        WeatherDetailsContainer(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < dailyForecast.length; i++) ...<Widget>[
                _ForecastDayRow(
                  day: dailyForecast[i],
                  temperatureUnits: temperatureUnits,
                  isLast: i == dailyForecast.length - 1,
                  isExtraSmall: isExtraSmall,
                  globalMin: globalMin,
                  globalMax: globalMax,
                ),
                if (i < dailyForecast.length - 1)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ForecastDayRow extends StatelessWidget {
  const _ForecastDayRow({
    required this.day,
    required this.temperatureUnits,
    required this.isLast,
    required this.isExtraSmall,
    required this.globalMin,
    required this.globalMax,
  });

  final ForecastDayDomain day;
  final TemperatureUnits temperatureUnits;
  final bool isLast;
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
        horizontal: isExtraSmall ? 8 : 16,
        vertical: isExtraSmall ? 8 : 12,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: isExtraSmall ? 32 : 44,
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
          SizedBox(width: isExtraSmall ? 4 : 8),
          Text(
            day.toCondition().toEmoji,
            style: TextStyle(fontSize: isExtraSmall ? 18 : 24),
          ),
          const Spacer(),
          SizedBox(
            width: isExtraSmall ? 28 : 40,
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
          const SizedBox(width: 4),
          Expanded(
            flex: isExtraSmall ? 2 : 4,
            child: _TemperatureRangeBar(
              min: day.minTemp,
              max: day.maxTemp,
              globalMin: globalMin,
              globalMax: globalMax,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: isExtraSmall ? 28 : 40,
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

class _TemperatureRangeBar extends StatelessWidget {
  const _TemperatureRangeBar({
    required this.min,
    required this.max,
    required this.globalMin,
    required this.globalMax,
  });

  final double min;
  final double max;
  final double globalMin;
  final double globalMax;

  @override
  Widget build(BuildContext context) {
    final double range = globalMax - globalMin;
    final double start = (min - globalMin) / range;
    final double end = (max - globalMin) / range;

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: (end - start).clamp(0.05, 1.0),
        alignment: Alignment(start * 2 - 1, 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: <Color>[Colors.blue, Colors.orange],
            ),
          ),
        ),
      ),
    );
  }
}

extension on ForecastDayDomain {
  WeatherCondition toCondition() {
    switch (weatherCode) {
      case 0:
        return WeatherCondition.clear;
      case 1:
      case 2:
      case 3:
      case 45:
      case 48:
        return WeatherCondition.cloudy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
      case 95:
      case 96:
      case 99:
        return WeatherCondition.rainy;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return WeatherCondition.snowy;
      default:
        return WeatherCondition.unknown;
    }
  }
}
