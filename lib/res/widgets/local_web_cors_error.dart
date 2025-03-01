import 'package:flutter/material.dart';

class LocalWebCorsError extends StatelessWidget {
  const LocalWebCorsError({
    required double cornerRadius,
    super.key,
  }) : _cornerRadius = cornerRadius;

  final double _cornerRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_cornerRadius),
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          'Error: Local Environment Setup Required\nTo run this '
          'application locally on web, please use the following '
          'command:\n\nflutter run -d chrome --web-browser-flag '
          '"--disable-web-security"\n\nThis step is necessary to '
          'bypass CORS restrictions during local development. '
          'Please note that this flag should only be used in a '
          'development environment and never in production.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
          ),
        ),
      ),
    );
  }
}
