import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weather_fit/entities/enums/outfit_image_source.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/weather/ui/error/outfit_image_error_widget.dart';

class OutfitImageWidget extends StatelessWidget {
  const OutfitImageWidget({
    required this.outfitImage,
    required this.onRefresh,
    this.fit = BoxFit.fitHeight,
    super.key,
  });

  final OutfitImage outfitImage;
  final RefreshCallback onRefresh;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        clipBehavior: Clip.antiAlias,
        child: switch (outfitImage.source) {
          OutfitImageSource.asset => Image.asset(
            outfitImage.path,
            fit: fit,
            errorBuilder: _errorBuilder,
          ),
          OutfitImageSource.file => Image.file(
            File(outfitImage.path),
            fit: fit,
            errorBuilder: _errorBuilder,
          ),
        },
      ),
    );
  }

  Widget _errorBuilder(BuildContext _, Object error, StackTrace? _) {
    debugPrint(
      '⚠️ Failed to load outfit image: "${outfitImage.path}". '
      'Error: $error\n'
      'Fallback UI displayed.',
    );
    return OutfitImageErrorWidget(onRefresh: onRefresh);
  }
}
