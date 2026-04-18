import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/extensions/color_extensions.dart';
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
      final WeatherCondition effectiveCondition =
          condition ??
          context.select((WeatherBloc bloc) => bloc.state.weather.condition);

      return SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _getGradientColors(effectiveCondition, context),
            ),
          ),
        ),
      );
    }
  }

  List<Color> _getGradientColors(
    WeatherCondition condition,
    BuildContext context,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color baseColor = colorScheme.primaryContainer;

    final int hour = DateTime.now().hour;
    final bool isNight =
        hour < WeatherCondition.dayStartHour ||
        hour >= WeatherCondition.nightStartHour;

    if (isNight) {
      return <Color>[
        colorScheme.surfaceContainerHighest,
        colorScheme.surfaceContainerLow,
        colorScheme.surface,
      ];
    } else {
      switch (condition) {
        case WeatherCondition.clear:
          return <Color>[
            baseColor,
            baseColor.brighten(20),
            baseColor.brighten(40),
          ];
        case WeatherCondition.rainy:
          return <Color>[
            baseColor.darken(10),
            baseColor.darken(20),
            baseColor.darken(30),
          ];
        case WeatherCondition.cloudy:
          return <Color>[baseColor, baseColor.darken(10), baseColor.darken(20)];
        case WeatherCondition.snowy:
          return <Color>[
            baseColor.brighten(30),
            baseColor.brighten(40),
            baseColor.brighten(50),
          ];
        case WeatherCondition.unknown:
          return <Color>[
            baseColor,
            baseColor.brighten(10),
            baseColor.brighten(33),
            baseColor.brighten(50),
          ];
      }
    }
  }
}
