import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/extensions/color_extensions.dart';
import 'package:weather_fit/res/widgets/weather_pattern.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class Background extends StatelessWidget {
  const Background({this.condition, super.key});

  final WeatherCondition? condition;

  @override
  Widget build(BuildContext context) {
    if (context.isExtraSmallScreen) {
      return const SizedBox.expand(child: ColoredBox(color: Colors.black));
    } else {
      final Weather weather = context.select(
        (WeatherBloc bloc) => bloc.state.weather,
      );
      final WeatherCondition effectiveCondition =
          condition ?? weather.condition;

      final bool isWeatherBackgroundEnabled = context.select(
        (SettingsBloc bloc) => bloc.state.isWeatherBackgroundEnabled,
      );

      final bool debugForceNight = context.select(
        (SettingsBloc bloc) => bloc.state.debugForceNight,
      );

      final bool isNight = debugForceNight || (weather.isDay == false);

      return SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const <double>[0.0, 0.35, 0.65, 1.0],
              colors: _getGradientColors(
                effectiveCondition,
                context,
                isNight: isNight,
              ),
            ),
          ),
          child: isWeatherBackgroundEnabled
              ? WeatherPattern(condition: effectiveCondition, isNight: isNight)
              : null,
        ),
      );
    }
  }

  List<Color> _getGradientColors(
    WeatherCondition condition,
    BuildContext context, {
    required bool isNight,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color baseColor = colorScheme.primaryContainer;

    switch (condition) {
      case WeatherCondition.clear:
        return isNight
            ? <Color>[
                baseColor.darken(65),
                baseColor.darken(75),
                baseColor.darken(85),
                baseColor.darken(95),
              ]
            : <Color>[
                baseColor,
                baseColor.brighten(15),
                baseColor.brighten(30),
                baseColor.brighten(45),
              ];
      case WeatherCondition.rainy:
        return isNight
            ? <Color>[
                baseColor.darken(50),
                baseColor.darken(60),
                baseColor.darken(70),
                baseColor.darken(80),
              ]
            : <Color>[
                baseColor.darken(5),
                baseColor.darken(15),
                baseColor.darken(25),
                baseColor.darken(35),
              ];
      case WeatherCondition.cloudy:
        return isNight
            ? <Color>[
                baseColor.darken(55),
                baseColor.darken(65),
                baseColor.darken(75),
                baseColor.darken(85),
              ]
            : <Color>[
                baseColor,
                baseColor.darken(10),
                baseColor.darken(15),
                baseColor.darken(20),
              ];
      case WeatherCondition.snowy:
        return isNight
            ? <Color>[
                baseColor.darken(45),
                baseColor.darken(55),
                baseColor.darken(65),
                baseColor.darken(75),
              ]
            : <Color>[
                baseColor.brighten(25),
                baseColor.brighten(35),
                baseColor.brighten(45),
                baseColor.brighten(55),
              ];
      case WeatherCondition.unknown:
        return isNight
            ? <Color>[
                baseColor.darken(60),
                baseColor.darken(70),
                baseColor.darken(80),
                baseColor.darken(90),
              ]
            : <Color>[
                baseColor,
                baseColor.brighten(10),
                baseColor.brighten(33),
                baseColor.brighten(50),
              ];
    }
  }
}
