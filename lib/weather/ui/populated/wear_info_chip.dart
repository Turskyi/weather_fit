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
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: radius),
      child: FittedBox(fit: BoxFit.scaleDown, child: child),
    );
  }
}
