import 'package:flutter/material.dart';

class WeatherError extends StatelessWidget {
  const WeatherError(this.message, {super.key});

  final String message;

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
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SelectableText(
            message,
            style: textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }
}
