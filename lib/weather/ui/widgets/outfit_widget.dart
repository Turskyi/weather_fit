import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/weather/ui/widgets/outfit_image_widget.dart';
import 'package:weather_fit/weather/ui/widgets/text_recommendation_widget.dart';

class OutfitWidget extends StatelessWidget {
  const OutfitWidget({
    required this.outfitImage,
    required this.onRefresh,
    this.outfitRecommendation = '',
    super.key,
  });

  final OutfitImage outfitImage;
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
      final String randomKey =
          _defaultMessageKeys[Random().nextInt(_defaultMessageKeys.length)];
      displayText = translate(randomKey);
    }

    final bool isNarrowScreen = context.isNarrowScreen;

    final BorderRadius borderRadius = BorderRadius.circular(20.0);

    final Size outfitSize = _getOutfitImageSize(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        // Match the ClipRRect's radius.
        borderRadius: borderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
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
        width: outfitSize.width,
        height: outfitSize.height,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: outfitImage.isEmpty
              ? TextRecommendationWidget(displayText: displayText)
              : isNarrowScreen
              ? ColoredBox(
                  color: colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      Expanded(
                        flex: 5,
                        child: ClipRRect(
                          borderRadius: borderRadius,
                          child: OutfitImageWidget(
                            outfitImage: outfitImage,
                            onRefresh: onRefresh,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(6),
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
                      child: OutfitImageWidget(
                        outfitImage: outfitImage,
                        onRefresh: onRefresh,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: colorScheme.surface,
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

  Size _getOutfitImageSize(BuildContext context) {
    if (context.isExtraSmallScreen) {
      return const Size(180, 236);
    } else if (context.isNarrowScreen) {
      return const Size(400, 520);
    } else {
      return const Size(520, 400);
    }
  }
}
