import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';

class WeatherShimmer extends StatelessWidget {
  const WeatherShimmer({this.locationName, super.key});

  final String? locationName;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 40),
          if (locationName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                locationName!,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w200,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            const LocationNameShimmer(),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: TemperatureShimmer(),
          ),
          const SizedBox(height: 40),
          const OutfitShimmer(),
          const SizedBox(height: 24),
          const DailyForecastShimmer(),
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
        height: 56, // Matched to displayMedium height
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
        height: 48, // Adjusted to better match displaySmall height
        width: 100,
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
      height = 236; // Matches _getOutfitImageSize
    } else if (isNarrow) {
      height = 520; // Matches _getOutfitImageSize
    }

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface.withValues(alpha: 0.5),
      child: Container(
        height: height,
        width: isExtraSmall ? 180 : 400, // Matches _getOutfitImageSize
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
        height: 122, // Approximate height of DailyForecast
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
        height: 75, // Matches WeatherIcon._iconSize
        width: 75,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
