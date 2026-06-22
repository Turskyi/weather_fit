import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/populated/weather_additional_metrics_grid.dart';
import 'package:weather_fit/weather/ui/populated/weather_feels_like_card.dart';
import 'package:weather_fit/weather/ui/populated/weather_hourly_forecast_section.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherDetailsSection extends StatefulWidget {
  const WeatherDetailsSection({required this.weather, super.key});

  final Weather weather;

  @override
  State<WeatherDetailsSection> createState() => _WeatherDetailsSectionState();
}

class _WeatherDetailsSectionState extends State<WeatherDetailsSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (BuildContext context, WeatherState state) {
        // Try to get "current" data from the first hour of forecast if
        // the main weather object is missing metrics.
        final ForecastItemDomain? currentHour =
            state.dailyForecast?.forecast.firstOrNull;

        final Weather weatherToUse = widget.weather.copyWith(
          feelsLike:
              widget.weather.feelsLike ??
              (currentHour?.feelsLike != null
                  ? Temperature(value: currentHour!.feelsLike!)
                  : null),
          humidity: widget.weather.humidity ?? currentHour?.humidity,
          windSpeed: widget.weather.windSpeed ?? currentHour?.windSpeed,
          uvIndex: widget.weather.uvIndex ?? currentHour?.uvIndex,
          visibility: widget.weather.visibility ?? currentHour?.visibility,
          cloudCover: widget.weather.cloudCover ?? currentHour?.cloudCover,
          pressure: widget.weather.pressure ?? currentHour?.pressure,
          dewPoint: widget.weather.dewPoint ?? currentHour?.dewPoint,
        );

        return Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 16.0),
          child: Column(
            children: <Widget>[
              OutlinedButton(
                onPressed: _toggleExpanded,
                child: Text(translate('weather.details_button')),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Column(
                          children: <Widget>[
                            WeatherFeelsLikeCard(weather: weatherToUse),
                            const SizedBox(height: 16),
                            const WeatherHourlyForecastSection(),
                            const SizedBox(height: 16),
                            WeatherAdditionalMetricsGrid(weather: weatherToUse),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}
