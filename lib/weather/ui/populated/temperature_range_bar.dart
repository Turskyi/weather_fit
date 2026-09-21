import 'package:flutter/material.dart';

/// A horizontal temperature range bar that visualizes a daily temperature
/// range relative to the overall forecast period (e.g., a 5-day forecast).
///
/// ### How it works
/// * **Grey Track (Left and Right):** The full background track represents
///   the entire temperature spectrum of the forecast period, from [globalMin]
///   to [globalMax]. The grey unfilled area on the left shows how far the day's
///   minimum temperature ([min]) is above the overall period minimum
///   ([globalMin]). The grey unfilled area on the right shows how far the day's
///   maximum temperature ([max]) is below the overall period maximum
///   ([globalMax]).
/// * **Color Range (Middle):** The filled gradient bar in the middle
///   represents the daily temperature range, spanning from [min] on its left
///   edge to [max] on its right edge. Its position and width within the track
///   are proportional to where the day's temperatures fall within the total
///   range ([globalMin] to [globalMax]). The gradient transitions from a cool
///   color (e.g., blue for [min]) to a warm color (e.g., orange for [max]).
class TemperatureRangeBar extends StatelessWidget {
  /// Creates a [TemperatureRangeBar].
  const TemperatureRangeBar({
    required this.min,
    required this.max,
    required this.globalMin,
    required this.globalMax,
    this.gradientColors = const <Color>[Colors.blue, Colors.orange],
    super.key,
  });

  /// The minimum temperature for this specific day.
  final double min;

  /// The maximum temperature for this specific day.
  final double max;

  /// The lowest minimum temperature across all forecast days.
  final double globalMin;

  /// The highest maximum temperature across all forecast days.
  final double globalMax;

  /// The colors used for the daily temperature gradient bar.
  ///
  /// Defaults to blue (representing cooler minimum temperatures) fading to
  /// orange (representing warmer maximum temperatures).
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    final double range = globalMax - globalMin;
    final double start;
    final double end;

    if (range > 0) {
      start = (min - globalMin) / range;
      end = (max - globalMin) / range;
    } else {
      start = 0.0;
      end = 1.0;
    }

    final double widthFactor = (end - start).clamp(0.05, 1.0);
    final double alignmentX = start * 2 - 1;

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: Alignment(alignmentX, 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(colors: gradientColors),
          ),
        ),
      ),
    );
  }
}
