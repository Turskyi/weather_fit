import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/weather/ui/weather_icon.dart';

import '../bloc/weather_bloc.dart';

class WeatherContent extends StatelessWidget {
  const WeatherContent({
    required this.weather,
    required this.child,
    required this.onRefresh,
    super.key,
  });

  final Weather weather;
  final Widget child;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? cityTextStyle = theme.textTheme.displayMedium;
    final String countryCode = weather.countryCode.toLowerCase();
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 48),
            if (!weather.neverUpdated)
              WeatherIcon(condition: weather.condition),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (countryCode.isNotEmpty)
                  SvgPicture.network(
                    'https://open-meteo.com/images/country-flags/'
                    '$countryCode.svg',
                    height: cityTextStyle?.fontSize,
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    child: Text(
                      weather.locationName,
                      style: cityTextStyle?.copyWith(
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!weather.neverUpdated)
              Text(
                weather.formattedTemperature,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (weather.neverUpdated)
              Text(weather.formattedLastUpdatedDateTime)
            else
              Text(
                'Last Updated on ${weather.formattedLastUpdatedDateTime}',
              ),
            const SizedBox(height: 24),
            if (!weather.neverUpdated) child,
            const SizedBox(height: 24),
            BlocBuilder<WeatherBloc, WeatherState>(
              builder: (_, WeatherState state) {
                if (state is! LoadingOutfitState &&
                    state is! WeatherLoadingState &&
                    weather.needsRefresh) {
                  return ElevatedButton(
                    onPressed: onRefresh,
                    child: const Text('Check Latest Weather'),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
