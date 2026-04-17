import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A custom scroll indicator for Wear OS that displays a curved line (arc)
/// along the edge of a circular screen, satisfying the "PositionIndicator"
/// requirement for Wear OS Quality Guidelines.
class WearPositionIndicator extends StatefulWidget {
  const WearPositionIndicator({
    required this.child,
    required this.controller,
    super.key,
  });

  final Widget child;
  final ScrollController controller;

  @override
  State<WearPositionIndicator> createState() => _WearPositionIndicatorState();
}

class _WearPositionIndicatorState extends State<WearPositionIndicator> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleScrollNotification);
  }

  @override
  void didUpdateWidget(WearPositionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleScrollNotification);
      widget.controller.addListener(_handleScrollNotification);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleScrollNotification);
    super.dispose();
  }

  void _handleScrollNotification() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        IgnorePointer(
          child: CustomPaint(
            painter: _PositionIndicatorPainter(
              controller: widget.controller,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _PositionIndicatorPainter extends CustomPainter {
  const _PositionIndicatorPainter({
    required this.controller,
    required this.color,
  });

  final ScrollController controller;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (!controller.hasClients || !controller.position.hasContentDimensions) {
      return;
    }

    final ScrollMetrics metrics = controller.position;
    final double extentBefore = metrics.pixels;
    final double extentInside = metrics.viewportDimension;
    final double extentTotal = metrics.maxScrollExtent + extentInside;

    if (extentTotal <= extentInside) return;

    final double scrollProportion = extentBefore / metrics.maxScrollExtent;
    final double viewProportion = extentInside / extentTotal;

    // We draw an arc on the right side of the screen.
    // Total available arc for the indicator is about 90 degrees (from -45 to
    // 45).
    const double totalArcRange = math.pi / 2;
    final double indicatorArcLength = (totalArcRange * viewProportion).clamp(
      0.1,
      totalArcRange,
    );
    final double startAngle =
        -totalArcRange / 2 +
        (totalArcRange - indicatorArcLength) * scrollProportion;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (math.min(size.width, size.height) / 2) - 3,
    );

    // Use a negative startAngle and draw it on the right side (0 is right
    // middle).
    // The angles in drawArc are in radians. 0 is 3 o'clock.
    canvas.drawArc(rect, startAngle, indicatorArcLength, false, paint);
  }

  @override
  bool shouldRepaint(covariant _PositionIndicatorPainter oldDelegate) {
    return true; // We repaint on every scroll change.
  }
}
