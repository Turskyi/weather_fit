import 'package:flutter/material.dart';

class LocalWebCorsError extends StatelessWidget {
  const LocalWebCorsError({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '🫠',
          style: TextStyle(fontSize: textTheme.displayLarge?.fontSize),
        ),
        Text(
          'Something went wrong!',
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 400,
          height: 400,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
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
          ),
        ),
      ],
    );
  }
}
