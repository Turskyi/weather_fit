import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';

class WeatherShimmer extends StatelessWidget {
  const WeatherShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 40),
          LocationNameShimmer(),
          SizedBox(height: 20),
          TemperatureShimmer(),
          SizedBox(height: 40),
          OutfitShimmer(),
          SizedBox(height: 24),
          DailyForecastShimmer(),
        ],
      ),
    );
  }
}

class LocationNameShimmer extends StatelessWidget {
  const LocationNameShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface.withValues(alpha: 0.5),
      child: Container(
        height: 40,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class TemperatureShimmer extends StatelessWidget {
  const TemperatureShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface.withValues(alpha: 0.5),
      child: Container(
        height: 60,
        width: 100,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class OutfitShimmer extends StatelessWidget {
  const OutfitShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isExtraSmall = context.isExtraSmallScreen;
    final bool isNarrow = context.isNarrowScreen;

    double height = 400;
    if (isExtraSmall) {
      height = 300;
    } else if (isNarrow) {
      height = 460;
    }

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface.withValues(alpha: 0.5),
      child: Container(
        height: height,
        width: isExtraSmall ? 250 : 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class DailyForecastShimmer extends StatelessWidget {
  const DailyForecastShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface.withValues(alpha: 0.5),
      child: Container(
        height: 100,
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class WeatherIconShimmer extends StatelessWidget {
  const WeatherIconShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface.withValues(alpha: 0.5),
      child: Container(
        height: 64,
        width: 64,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
