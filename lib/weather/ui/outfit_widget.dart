import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weather_fit/weather/ui/text_recommendation_widget.dart';

class OutfitWidget extends StatelessWidget {
  const OutfitWidget({
    required this.needsRefresh,
    required this.filePath,
    this.outfitRecommendation = '',
    super.key,
  });

  final bool needsRefresh;
  final String filePath;
  final String outfitRecommendation;

  static final List<String> _defaultMessages = <String>[
    '🛑 Oops! No outfit suggestion available.',
    '🤷 Looks like we couldn’t pick an outfit this time.',
    '🎨 No recommendation? Time to mix & match your own style!',
    '✨ Your fashion instincts take the lead today!',
    '🤖 AI is taking a fashion break. Try again!',
    '😴 No outfit picked—maybe today is a pajama day?',
    '👕 No outfit available.',
    '🚫 no recommendation.',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String displayText = outfitRecommendation.isNotEmpty
        ? outfitRecommendation
        : _defaultMessages[Random().nextInt(_defaultMessages.length)];

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isNarrowScreen = screenWidth < 500;
    final BorderRadius borderRadius = BorderRadius.circular(20.0);
    return DecoratedBox(
      decoration: BoxDecoration(
        // Match the ClipRRect's radius.
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            // How far the shadow spreads.
            spreadRadius: 2,
            // How blurry the shadow is.
            blurRadius: 8,
            // Vertical offset (positive for down).
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: isNarrowScreen ? 400 : 520,
        height: isNarrowScreen ? 520 : 400,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: kIsWeb || filePath.isEmpty
              ? TextRecommendationWidget(displayText: displayText)
              : isNarrowScreen
                  ? ColoredBox(
                      color: colorScheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Image.file(
                              File(filePath),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              child: SelectableText(
                                displayText,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Image.file(File(filePath), fit: BoxFit.cover),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: theme.colorScheme.surface,
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: SelectableText(
                                displayText,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
