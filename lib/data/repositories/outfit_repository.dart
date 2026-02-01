import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/data_sources/remote/remote_data_source.dart';
import 'package:weather_fit/entities/enums/outfit_image_source.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_repository/weather_repository.dart';

class OutfitRepository {
  const OutfitRepository(this._localDataSource, this._remoteDataSource);

  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;

  static const String _precipitation = 'precipitation';

  Future<OutfitImage> getOutfitImage(Weather weather) async {
    final double temperatureValue = _getTemperatureInCelsius(weather);
    final int roundedTemp = temperatureValue.round();
    final List<String> fileNames = _getFileNames(
      weather.condition,
      roundedTemp,
    );

    // On web, we cannot use dart:io Directory or File,
    // so we use network source directly.
    if (kIsWeb) {
      return OutfitImage(
        paths: fileNames
            .map((String name) => '${constants.remoteOutfitBaseUrl}$name')
            .toList(),
        source: OutfitImageSource.network,
      );
    } else if (roundedTemp % 10 == 0) {
      // 1. If the temperature ends with 0, return the asset image paths
      // immediately.
      return OutfitImage(
        paths: getOutfitImageAssetPaths(weather),
        source: OutfitImageSource.asset,
      );
    } else {
      // 2. If the temperature does not end with 0, handle remote/cached image.
      try {
        final Directory directory = await _localDataSource.getAppDirectory();
        final List<String> filePaths = <String>[];

        for (final String fileName in fileNames) {
          final String filePath = '${directory.path}/$fileName';

          // Check if the image is already downloaded locally.
          if (await _localDataSource.fileExists(filePath)) {
            filePaths.add(filePath);
            continue;
          }

          // Attempt to download from remote source.
          final List<int> bytes = await _remoteDataSource
              .downloadOutfitImage(fileName)
              .timeout(const Duration(seconds: 5));

          // Save to local app storage.
          final File file = File(filePath);
          await file.writeAsBytes(bytes);
          filePaths.add(filePath);
        }

        return OutfitImage(paths: filePaths, source: OutfitImageSource.file);
      } catch (e) {
        debugPrint(
          'Error handling remote outfit image: $e. Falling back to asset.',
        );
        // 3. Fallback to existing asset-based logic.
        return OutfitImage(
          paths: getOutfitImageAssetPaths(weather),
          source: OutfitImageSource.asset,
        );
      }
    }
  }

  List<String> getOutfitImageAssetPaths(Weather weather) {
    return _localDataSource.getOutfitImageAssetPaths(weather);
  }

  String getOutfitRecommendation(Weather weather) {
    return _localDataSource.getOutfitRecommendation(weather);
  }

  /// Orchestrates getting the outfit images and ensuring they are saved as
  /// files for external consumers like Home Widgets.
  Future<List<String>> downloadAndSaveImages(Weather weather) async {
    final OutfitImage outfitImage = await getOutfitImage(weather);
    final List<String> savedPaths = <String>[];

    for (final String path in outfitImage.paths) {
      if (outfitImage.source == OutfitImageSource.file ||
          outfitImage.source == OutfitImageSource.network) {
        // It's already a file on disk or a network URL.
        savedPaths.add(path);
      } else {
        // It's a bundled asset, we need to "download" (copy) it to a file
        // so the Home Widget can access it.
        final String savedPath = await _localDataSource.downloadAndSaveImage(
          path,
        );
        savedPaths.add(savedPath);
      }
    }
    return savedPaths;
  }

  double _getTemperatureInCelsius(Weather weather) {
    double temperatureValue = weather.temperature.value;
    final TemperatureUnits units = weather.temperatureUnits;

    if (units.isFahrenheit) {
      temperatureValue = temperatureValue.toCelsius();
    }
    return temperatureValue;
  }

  List<String> _getFileNames(WeatherCondition condition, int roundedTemp) {
    if (condition.isUnknown) {
      return <String>[
        '${WeatherCondition.clear.name}_$roundedTemp.png',
        '${WeatherCondition.cloudy.name}_$roundedTemp.png',
        '${_precipitation}_$roundedTemp.png',
      ];
    } else {
      final String conditionName = _getConditionName(condition);
      return <String>['${conditionName}_$roundedTemp.png'];
    }
  }

  String _getConditionName(WeatherCondition condition) {
    return switch (condition) {
      WeatherCondition.clear => condition.name,
      WeatherCondition.cloudy => condition.name,
      WeatherCondition.rainy || WeatherCondition.snowy => _precipitation,
      _ => WeatherCondition.unknown.name,
    };
  }
}
