import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/enums/settings.dart';
import 'package:weather_repository/weather_repository.dart';

class LocalDataSource {
  const LocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  String getOutfitImageAssetPath(Weather weather) {
    final WeatherCondition condition = weather.condition;
    final double temperatureValue = weather.temperature.value;
    if (temperatureValue < -40) {
      return '${constants.outfitImagePath}-40.png';
    }

    // Round down temperature to nearest 10 degrees.
    int roundedTemp = (temperatureValue / 10).floor() * 10;

    // Clamp to -30...30.
    if (roundedTemp > 30) roundedTemp = 30;
    if (roundedTemp < -30) roundedTemp = -30;

    final String precipitation = 'precipitation';

    // Random condition for unknown states
    final List<String> possibleConditions = <String>[
      WeatherCondition.clear.name,
      WeatherCondition.cloudy.name,
      precipitation,
    ];

    // Handle unknowns early.
    if (condition.isUnknown) {
      final int index = Random().nextInt(possibleConditions.length);
      final String randomConditionName = possibleConditions[index];
      return '${constants.outfitImagePath}${randomConditionName}_$roundedTemp'
          '.png';
    }

    // Normalize snowy → precipitation for shared assets
    final String conditionName = switch (condition) {
      WeatherCondition.clear => condition.name,
      WeatherCondition.cloudy => condition.name,
      WeatherCondition.rainy || WeatherCondition.snowy => precipitation,
      _ => WeatherCondition.unknown.name,
    };

    return '${constants.outfitImagePath}${conditionName}_$roundedTemp.png';
  }

  String getOutfitRecommendation(Weather weather) {
    final double temperature = weather.temperature.value;
    final WeatherCondition condition = weather.condition;
    final TemperatureUnits units = weather.temperatureUnits;

    if (condition.isRainy) {
      return translate('outfit.rainy');
    } else if (condition.isSnowy) {
      return translate('outfit.snowy');
    } else if (temperature < 10 && units.isCelsius ||
        temperature < 50 && units.isFahrenheit) {
      return translate('outfit.cold');
    } else if (temperature >= 10 && temperature < 20 && units.isCelsius ||
        temperature >= 50 && temperature < 68 && units.isFahrenheit) {
      return translate('outfit.cool');
    } else if (temperature >= 20 && temperature < 30 && units.isCelsius ||
        temperature >= 68 && temperature < 86 && units.isFahrenheit) {
      return translate('outfit.warm');
    } else if (temperature >= 30 && units.isCelsius ||
        temperature >= 86 && units.isFahrenheit) {
      return translate('outfit.hot');
    } else {
      return translate('outfit.moderate');
    }
  }

  Future<String> downloadAndSaveImage(String assetPath) async {
    // Check if the platform is web OR macOS. If so, return early.
    // See issue: https://github.com/ABausG/home_widget/issues/137.
    if (kIsWeb || (!kIsWeb && Platform.isMacOS)) {
      return '';
    }
    try {
      // Load asset data as ByteData.
      final ByteData byteData = await rootBundle.load(assetPath);

      // Get the application documents directory.
      final Directory directory = await _getAppDirectory();
      final String filePath = '${directory.path}/outfit_image.png';
      // Write the bytes to the file.
      final File file = File(filePath);

      // Check if the file exists and delete it if it does.
      if (await file.exists()) {
        await file.delete();
      }

      // Ensure the directory exists.
      await directory.create(recursive: true);

      // Write the new image data.
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      // Invalidate the image cache.
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      return filePath;
    } catch (e) {
      // Handle potential errors (e.g., asset not found)
      debugPrint('Error saving asset image to file: $e');
      throw Exception('${translate('error.save_asset_image_failed')}: $e');
    }
  }

  Future<Directory> _getAppDirectory() async {
    if (!kIsWeb & Platform.isIOS) {
      const MethodChannel channel = MethodChannel(
        'weatherfit.shared/container',
      );
      final String path = await channel.invokeMethod(
        'getAppleAppGroupDirectory',
      );

      return Directory(path);
    } else {
      // On Android or other platforms, fallback to Documents directory.
      return getApplicationDocumentsDirectory();
    }
  }

  Future<bool> saveLanguageIsoCode(String languageIsoCode) {
    return _preferences.setString(
      Settings.languageIsoCode.key,
      languageIsoCode,
    );
  }

  String getLanguageIsoCode() {
    final String? savedLanguageIsoCode = _preferences.getString(
      Settings.languageIsoCode.key,
    );

    String defaultLanguageCode =
        PlatformDispatcher.instance.locale.languageCode;

    final String host = Uri.base.host;
    if (host.startsWith('${Language.uk.isoLanguageCode}.')) {
      // Sets the default locale for the intl package in Dart/Flutter to
      // Ukrainian.
      Intl.defaultLocale = Language.uk.isoLanguageCode;
      defaultLanguageCode = Language.uk.isoLanguageCode;
    }

    return savedLanguageIsoCode ?? defaultLanguageCode;
  }

  /// Saves the provided [location] to persistent storage as a JSON string.
  ///
  /// Returns a [Future] that completes with `true` if the value was
  /// successfully written to [SharedPreferences], or `false` if the operation
  /// failed.
  ///
  /// This is useful for caching the last selected or confirmed location
  /// locally, so the app can restore it on next launch without requiring user
  /// input.
  Future<bool> saveLocation(Location location) {
    final String json = jsonEncode(location.toJson());
    return _preferences.setString(Settings.location.key, json);
  }

  Location getLastSavedLocation() {
    final String jsonString = _preferences.getString(
          Settings.location.key,
        ) ??
        '';
    if (jsonString.isEmpty) {
      return const Location.empty();
    } else {
      try {
        final Object? decoded = jsonDecode(jsonString);
        if (decoded is Map<String, Object?>) {
          return Location.fromJson(decoded);
        }
      } catch (e) {
        debugPrint('Error parsing last saved location: $e');
      }
      return const Location.empty();
    }
  }
}
