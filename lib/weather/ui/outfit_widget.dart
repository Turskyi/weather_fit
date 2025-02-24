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
    this.onLoaded,
  });

  final bool needsRefresh;
  final String imageUrl;
  final VoidCallback? onLoaded;

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
                onLoaded?.call();
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
            if (exception is NetworkImageLoadException) {
              final int statusCode = exception.statusCode;
              if (statusCode == HttpStatus.forbidden && needsRefresh) {
                context.read<WeatherBloc>().add(const RefreshWeather());
              } else if (statusCode == 0 && kDebugMode && kIsWeb) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(_cornerRadius),
                  child: Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(16),
                    child: SelectableText(
                      'Error: Local Environment Setup Required\nTo run this '
                      'application locally on web, please use the following '
                      'command:\n\nflutter run -d chrome --web-browser-flag '
                      '"--disable-web-security"\n\nThis step is necessary to '
                      'bypass CORS restrictions during local development. '
                      'Please note that this flag should only be used in a '
                      'development environment and never in production.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            Theme.of(context).textTheme.titleMedium?.fontSize,
                      ),
                    ),
                  ),
                );
              }
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
