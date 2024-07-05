import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';

class OutfitWidget extends StatelessWidget {
  const OutfitWidget({
    super.key,
    required this.needsRefresh,
    required this.imageUrl,
    required this.onLoaded,
  });

  final bool needsRefresh;
  final String imageUrl;
  final VoidCallback onLoaded;

  double get _cornerRadius => kIsWeb ? 20 : 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cornerRadius),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              // Image is fully loaded
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onLoaded.call();
              });
              return child;
            } else {
              // Image is still loading
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue.withAlpha(90),
                  backgroundColor: Colors.transparent,
                  strokeAlign: BorderSide.strokeAlignOutside,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          },
          errorBuilder: (
            BuildContext context,
            Object exception,
            StackTrace? ___,
          ) {
            if (exception is NetworkImageLoadException &&
                exception.statusCode == HttpStatus.forbidden &&
                needsRefresh) {
              context.read<WeatherBloc>().add(const RefreshWeather());
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
