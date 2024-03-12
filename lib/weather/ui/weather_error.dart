import 'package:flutter/material.dart';

class WeatherError extends StatelessWidget {
  const WeatherError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text('🫠', style: TextStyle(fontSize: 64)),
        Text(
          'Something went wrong!',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        Text(
          message,
          style: theme.textTheme.headlineSmall,
        ),
      ],
    );
  }
}
