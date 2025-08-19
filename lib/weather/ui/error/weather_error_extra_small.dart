import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class WeatherErrorExtraSmall extends StatelessWidget {
  const WeatherErrorExtraSmall({
    required this.message,
    required this.onReportPressed,
    super.key,
  });

  final String message;
  final VoidCallback onReportPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 36, left: 16, right: 16),
      child: Column(
        children: <Widget>[
          Text(
            '🫠',
            style: TextStyle(fontSize: textTheme.titleLarge?.fontSize),
          ),
          Text(
            translate('error.something_went_wrong'),
            style: textTheme.titleSmall,
          ),
          Text(
            message,
            style: textTheme.labelSmall,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onReportPressed,
            child: Text(
              translate('error.report_issue'),
              style: textTheme.labelSmall?.copyWith(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
