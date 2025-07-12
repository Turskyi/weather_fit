import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/weather/ui/text_recommendation_widget.dart';

class OutfitWidget extends StatelessWidget {
  const OutfitWidget({
    required this.needsRefresh,
    required this.assetPath,
    required this.onRefresh,
    this.outfitRecommendation = '',
    super.key,
  });

  final bool needsRefresh;
  final String assetPath;
  final String outfitRecommendation;
  final RefreshCallback onRefresh;

  static final List<String> _defaultMessageKeys = <String>[
    'outfit.oops',
    'outfit.could_not_pick',
    'outfit.mix_and_match',
    'outfit.fashion_instincts',
    'outfit.pajama_day',
    'outfit.unavailable_short',
    'outfit.no_recommendation_short',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    String displayText;
    if (outfitRecommendation.isNotEmpty) {
      displayText = outfitRecommendation;
    } else {
      final String randomKey = _defaultMessageKeys[Random().nextInt(
        _defaultMessageKeys.length,
      )];
      displayText = translate(randomKey);
    }

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
          child: assetPath.isEmpty
              ? TextRecommendationWidget(displayText: displayText)
              : isNarrowScreen
                  ? ColoredBox(
                      color: colorScheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Image.asset(
                              assetPath,
                              fit: BoxFit.fitHeight,
                              errorBuilder: (
                                BuildContext context,
                                Object error,
                                __,
                              ) {
                                debugPrint(
                                  '⚠️ Failed to load outfit image on narrow '
                                  'screen: "$assetPath". '
                                  'Error: $error\n'
                                  'Fallback UI displayed.',
                                );
                                final ThemeData theme = Theme.of(context);
                                final TextTheme textTheme = theme.textTheme;

                                return Container(
                                  color: theme.colorScheme.surface,
                                  padding: const EdgeInsets.all(16),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: theme.colorScheme.error,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        translate(
                                          'unable_to_load_outfit_image',
                                        ),
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        translate(
                                          'please_try_refreshing_weather',
                                        ),
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: onRefresh,
                                        child: Text(
                                          translate(
                                            'get_new_outfit_suggestion',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
                          child: Image.asset(
                            assetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (
                              BuildContext _,
                              Object error,
                              StackTrace? ___,
                            ) {
                              debugPrint(
                                '⚠️ Failed to load outfit image on wide '
                                'screen: "$assetPath". '
                                'Error: $error\n'
                                'Fallback UI displayed.',
                              );
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: <Color>[
                                      colorScheme.primaryContainer,
                                      colorScheme.secondaryContainer,
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.all(20),
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  onPressed: onRefresh,
                                  child: Text(
                                    translate('get_new_outfit_suggestion'),
                                  ),
                                ),
                              );
                            },
                          ),
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
