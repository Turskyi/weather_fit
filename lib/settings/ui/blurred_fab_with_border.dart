import 'package:flutter/material.dart';

class BlurredFabWithBorder extends StatelessWidget {
  const BlurredFabWithBorder({
    required this.onPressed,
    super.key,
    this.tooltip,
    this.icon,
    this.borderWidth = 1,
  });

  final VoidCallback onPressed;
  final String? tooltip;
  final IconData? icon;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      // elevation: 0.00,
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Icon(
        icon,
        semanticLabel: tooltip,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
