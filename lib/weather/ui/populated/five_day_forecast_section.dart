import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/search/ui/widgets/wear_dialog.dart';
import 'package:weather_fit/weather/ui/populated/forecast_day_row.dart';
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
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    translate('weather.five_day_forecast_title'),
                    style: isExtraSmall
                        ? textTheme.labelLarge
                        : textTheme.titleMedium,
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  size: isExtraSmall ? 16 : 18,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showTemperatureBarInfoDialog(context),
              ),
            ],
          ),
        ),
        WeatherDetailsContainer(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < dailyForecast.length; i++) ...<Widget>[
                ForecastDayRow(
                  day: dailyForecast[i],
                  temperatureUnits: temperatureUnits,
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

  Future<void> _showTemperatureBarInfoDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        if (context.isExtraSmallScreen) {
          return WearDialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  translate('weather.temperature_bar_info_title'),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    dialogContext,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  translate('weather.temperature_bar_info_description'),
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: Navigator.of(dialogContext).pop,
                  child: Text(translate('ok')),
                ),
              ],
            ),
          );
        }
        return AlertDialog(
          title: Text(translate('weather.temperature_bar_info_title')),
          content: Text(translate('weather.temperature_bar_info_description')),
          actions: <Widget>[
            TextButton(
              onPressed: Navigator.of(dialogContext).pop,
              child: Text(translate('ok')),
            ),
          ],
        );
      },
    );
  }
}
