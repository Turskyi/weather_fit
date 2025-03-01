import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/res/widgets/loading_indicator.dart';
import 'package:weather_fit/res/widgets/local_web_cors_error.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';

class OutfitWidget extends StatelessWidget {
  const OutfitWidget({
    required this.needsRefresh,
    required this.imageUrl,
    required this.imagePath,
    super.key,
  });

  final bool needsRefresh;
  final String imageUrl;
  final String imagePath;

  double get _cornerRadius => kIsWeb ? 20 : 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cornerRadius),
        child: kIsWeb || imagePath.isEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (
                  _,
                  Widget child,
                  ImageChunkEvent? loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    // Image is fully loaded.
                    return child;
                  } else {
                    // Image is still loading.
                    return LoadingIndicator(loadingProgress: loadingProgress);
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
                      return LocalWebCorsError(cornerRadius: _cornerRadius);
                    }
                  }
                  return const SizedBox();
                },
              )
            : Image.file(File(imagePath), fit: BoxFit.cover),
      ),
    );
  }
}
