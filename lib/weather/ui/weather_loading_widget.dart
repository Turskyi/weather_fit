import 'package:flutter/material.dart';

class WeatherLoadingWidget extends StatelessWidget {
  const WeatherLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primaryColor.withAlpha(99),
          ),
          padding: const EdgeInsets.all(16.0),
          child: const Icon(
            Icons.cloud,
            size: 64,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          'Loading Weather',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
      ],
    );
  }
}
