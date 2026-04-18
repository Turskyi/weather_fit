import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/extensions/color_extensions.dart';
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
      final WeatherCondition effectiveCondition =
          condition ??
          context.select((WeatherBloc bloc) => bloc.state.weather.condition);

      final bool isWeatherBackgroundEnabled = context.select(
        (SettingsBloc bloc) => bloc.state.isWeatherBackgroundEnabled,
      );

      final bool debugForceNight = context.select(
        (SettingsBloc bloc) => bloc.state.debugForceNight,
      );

      final int hour = DateTime.now().hour;
      final bool isNight =
          debugForceNight ||
          hour < WeatherCondition.dayStartHour ||
          hour >= WeatherCondition.nightStartHour;

      return SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _getGradientColors(
                effectiveCondition,
                context,
                isNight: isNight,
              ),
            ),
          ),
          child: isWeatherBackgroundEnabled
              ? _WeatherPattern(condition: effectiveCondition, isNight: isNight)
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

    if (isNight) {
      return <Color>[
        colorScheme.surfaceContainerHighest,
        colorScheme.surfaceContainerLow,
        colorScheme.surface,
      ];
    }

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

class _WeatherPattern extends StatelessWidget {
  const _WeatherPattern({required this.condition, required this.isNight});

  final WeatherCondition condition;
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    final double fontSize =
        Theme.of(context).textTheme.displayLarge?.fontSize ?? 57;

    final String emoji = _getEmoji(condition, isNight);

    return IgnorePointer(
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: fontSize * 2,
          mainAxisSpacing: 40,
          crossAxisSpacing: 40,
        ),
        // Large number to ensure screen is filled
        itemCount: 200,
        itemBuilder: (BuildContext context, int index) {
          return Center(
            child: Opacity(
              opacity: isNight ? 0.05 : 0.15,
              child: Transform.rotate(
                angle: index % 2 == 0 ? 0.2 : -0.2,
                child: Text(emoji, style: TextStyle(fontSize: fontSize)),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getEmoji(WeatherCondition condition, bool isNight) {
    switch (condition) {
      case WeatherCondition.clear:
        return isNight ? '🌕' : '☀️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.cloudy:
        return isNight ? '☁️' : '🌥️';
      case WeatherCondition.snowy:
        return '🌨️';
      case WeatherCondition.unknown:
        return '❓';
    }
  }
}
