import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weather_fit/entities/weather.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/weather/ui/weather_icon.dart';

class WeatherPopulated extends StatelessWidget {
  const WeatherPopulated({
    required this.weather,
    required this.onRefresh,
    this.child = const SizedBox(),
    super.key,
  });

  final Weather weather;
  final RefreshCallback onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? cityTextStyle = theme.textTheme.displayMedium;
    return Stack(
      children: <Widget>[
        const Background(),
        RefreshIndicator(
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 48),
                  WeatherIcon(condition: weather.condition),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.network(
                        'https://open-meteo.com/images/country-flags/${weather.countryCode}.svg',
                        height: cityTextStyle?.fontSize ?? 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        weather.city,
                        style: cityTextStyle?.copyWith(
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    weather.formattedTemperature,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '''Last Updated at ${TimeOfDay.fromDateTime(weather.lastUpdated ?? DateTime(0)).format(context)}''',
                  ),
                  const SizedBox(height: 24),
                  child,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
