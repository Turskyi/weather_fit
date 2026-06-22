import 'dart:ui';

import 'package:flutter/material.dart';

class WeatherDetailsContainer extends StatelessWidget {
  const WeatherDetailsContainer({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }
}
