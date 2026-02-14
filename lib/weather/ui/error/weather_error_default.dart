import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class WeatherErrorDefault extends StatelessWidget {
  const WeatherErrorDefault({
    required this.message,
    required this.onRetryPressed,
    super.key,
  });

  final String message;
  final VoidCallback onRetryPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return SelectionArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: MediaQuery.paddingOf(context).top),
          Text(
            '🫠',
            style: TextStyle(fontSize: textTheme.displayLarge?.fontSize),
          ),
          Text(
            translate('error.something_went_wrong'),
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(message, style: textTheme.headlineSmall),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onRetryPressed,
            child: Text(translate('try_again')),
          ),
        ],
      ),
    );
  }
}
