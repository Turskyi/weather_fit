import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';

class WeatherShimmer extends StatelessWidget {
  const WeatherShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isExtraSmall = context.isExtraSmallScreen;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface.withValues(alpha: 0.5),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 40),
            // Location name placeholder
            Container(
              height: 40,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 20),
            // Temperature placeholder
            Container(
              height: 60,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 40),
            // Outfit placeholder
            Container(
              height: isExtraSmall ? 300 : 400,
              width: isExtraSmall ? 250 : 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
