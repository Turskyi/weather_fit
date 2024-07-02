import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:weather_fit/entities/weather.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
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
                    'Last Updated on ${_formatDateTime(weather.lastUpdated)}',
                  ),
                  const SizedBox(height: 24),
                  child,
                  const SizedBox(height: 24),
                  BlocBuilder<WeatherBloc, WeatherState>(
                    builder: (_, WeatherState state) {
                      if (state is! WeatherLoadingState && _needsRefresh) {
                        return ElevatedButton(
                          onPressed: onRefresh,
                          child: const Text('Refresh'),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Output: e.g., "Dec 12, Monday at 03:45 PM"
  String _formatDateTime(DateTime? lastUpdated) {
    if (lastUpdated != null) {
      final DateFormat formatter = DateFormat('MMM dd, EEEE \'at\' hh:mm a');
      return formatter.format(lastUpdated);
    } else {
      return 'Never updated';
    }
  }

  bool get _needsRefresh {
    const int fiveMinutes = 5;
    final int difference =
        DateTime.now().difference(weather.lastUpdated ?? DateTime(0)).inMinutes;
    return difference > fiveMinutes;
  }
}
