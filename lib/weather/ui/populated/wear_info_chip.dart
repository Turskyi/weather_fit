import 'package:flutter/material.dart';

class WearInfoChip extends StatelessWidget {
  const WearInfoChip({
    required this.size,
    required this.radius,
    required this.color,
    required this.child,
    super.key,
  });

  final double size;
  final BorderRadius radius;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: radius),
      child: child,
    );
  }
}
