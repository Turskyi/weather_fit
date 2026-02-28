import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';

class PlannerShimmer extends StatelessWidget {
  const PlannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = _getOutfitImageSize(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surface.withValues(alpha: 0.5),
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }

  Size _getOutfitImageSize(BuildContext context) {
    if (context.isExtraSmallScreen) {
      return const Size(180, 236);
    } else if (context.isNarrowScreen) {
      return const Size(400, 520);
    } else {
      return const Size(520, 400);
    }
  }
}
