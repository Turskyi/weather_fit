import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/data_sources/remote/remote_data_source.dart';
import 'package:weather_fit/entities/enums/outfit_image_source.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_repository/weather_repository.dart';

class OutfitRepository {
  const OutfitRepository(this._localDataSource, this._remoteDataSource);

  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;

  Future<OutfitImage> getOutfitImage(Weather weather) async {
    final double temperatureValue = _getTemperatureInCelsius(weather);
    final int roundedTemp = temperatureValue.round();

    // On web, we cannot use dart:io Directory or File,
    // so we use network source directly.
    if (kIsWeb) {
      final String conditionName = _getConditionName(weather.condition);
      final String fileName = '${conditionName}_$roundedTemp.png';
      const String baseUrl =
          'https://raw.githubusercontent.com/Turskyi/weather_fit/refs/heads/master/outfits/';
      return OutfitImage(
        path: '$baseUrl$fileName',
        source: OutfitImageSource.network,
      );
    }

    // 1. If the temperature ends with 0, return the asset image path
    // immediately.
    if (roundedTemp % 10 == 0) {
      return OutfitImage(
        path: getOutfitImageAssetPath(weather),
        source: OutfitImageSource.asset,
      );
    }

    // 2. If the temperature does not end with 0, handle remote/cached image.
    try {
      final String conditionName = _getConditionName(weather.condition);
      final String fileName = '${conditionName}_$roundedTemp.png';
      final Directory directory = await _localDataSource.getAppDirectory();
      final String filePath = '${directory.path}/$fileName';

      // Check if the image is already downloaded locally.
      if (await _localDataSource.fileExists(filePath)) {
        return OutfitImage(path: filePath, source: OutfitImageSource.file);
      }

      // Attempt to download from remote source.
      final List<int> bytes = await _remoteDataSource
          .downloadOutfitImage(fileName)
          .timeout(const Duration(seconds: 5));

      // Save to local app storage.
      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      return OutfitImage(path: filePath, source: OutfitImageSource.file);
    } catch (e) {
      debugPrint(
        'Error handling remote outfit image: $e. Falling back to asset.',
      );
      // 3. Fallback to existing asset-based logic.
      return OutfitImage(
        path: getOutfitImageAssetPath(weather),
        source: OutfitImageSource.asset,
      );
    }
  }

  String getOutfitImageAssetPath(Weather weather) {
    return _localDataSource.getOutfitImageAssetPath(weather);
  }

  String getOutfitRecommendation(Weather weather) {
    return _localDataSource.getOutfitRecommendation(weather);
  }

  /// Orchestrates getting the outfit image and ensuring it's saved as a file
  /// for external consumers like Home Widgets.
  Future<String> downloadAndSaveImage(Weather weather) async {
    final OutfitImage outfitImage = await getOutfitImage(weather);

    if (outfitImage.source == OutfitImageSource.file) {
      // It's already a file on disk (either cached or freshly downloaded).
      return outfitImage.path;
    } else if (outfitImage.source == OutfitImageSource.network) {
      // For network images on web, we don't have a local file path to return.
      return outfitImage.path;
    } else {
      // It's a bundled asset, we need to "download" (copy) it to a file
      // so the Home Widget can access it.
      return _localDataSource.downloadAndSaveImage(outfitImage.path);
    }
  }

  double _getTemperatureInCelsius(Weather weather) {
    double temperatureValue = weather.temperature.value;
    final TemperatureUnits units = weather.temperatureUnits;

    if (units.isFahrenheit) {
      temperatureValue = temperatureValue.toCelsius();
    }
    return temperatureValue;
  }

  String _getConditionName(WeatherCondition condition) {
    const String precipitation = 'precipitation';
    return switch (condition) {
      WeatherCondition.clear => condition.name,
      WeatherCondition.cloudy => condition.name,
      WeatherCondition.rainy || WeatherCondition.snowy => precipitation,
      _ => WeatherCondition.unknown.name,
    };
  }
}
