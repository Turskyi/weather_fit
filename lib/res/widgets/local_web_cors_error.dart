import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

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
          translate('error.something_went_wrong'),
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
                translate('error.cors'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: textTheme.titleMedium?.fontSize,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
