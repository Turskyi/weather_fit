import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/enums/settings.dart';
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_repository/weather_repository.dart';

class LocalDataSource {
  const LocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  String getOutfitImageAssetPath(Weather weather) {
    final WeatherCondition condition = weather.condition;
    double temperatureValue = weather.temperature.value;
    final TemperatureUnits units = weather.temperatureUnits;

    if (units.isFahrenheit) {
      temperatureValue = temperatureValue.toCelsius();
    }

    if (temperatureValue < -40) {
      return '${constants.outfitImagePath}-40.png';
    }

    // Round down temperature to nearest 10 degrees.
    int roundedTemp = (temperatureValue / 10).floor() * 10;

    // Clamp to -30...30.
    if (roundedTemp > 30) roundedTemp = 30;
    if (roundedTemp < -30) roundedTemp = -30;

    const String precipitation = 'precipitation';

    // Random condition for unknown states.
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
    final String locale = getLanguageIsoCode();
    final double temperature = weather.temperature.value;
    final WeatherCondition condition = weather.condition;
    final TemperatureUnits units = weather.temperatureUnits;

    final Map<String, String> outfitEn = <String, String>{
      'outfit.rainy': 'Take an umbrella',
      'outfit.rainy_hot': 'Hot & rainy — light clothes + umbrella',
      'outfit.snowy': 'Dress warmly, it\'s snowing!',
      'outfit.cold': 'Wear a warm jacket',
      'outfit.cool': 'Maybe bring a light jacket',
      'outfit.warm': 'Light clothing should be fine',
      'outfit.hot': 'It\'s hot! Dress lightly',
      'outfit.moderate': 'Comfortable weather today',
    };

    final Map<String, String> outfitUk = <String, String>{
      'outfit.rainy': 'Візьміть парасольку',
      'outfit.rainy_hot': 'Спекотно й дощ — легкий одяг і парасолька',
      'outfit.snowy': 'Одягніться тепло, йде сніг!',
      'outfit.cold': 'Одягніться тепло',
      'outfit.cool': 'Можливо, знадобиться легка куртка',
      'outfit.warm': 'Легкий одяг буде доречний',
      'outfit.hot': 'Спекотно! Одягайтесь легко',
      'outfit.moderate': 'Сьогодні комфортна погода',
    };

    final Map<String, String> outfit =
        locale.startsWith(Language.uk.isoLanguageCode) ? outfitUk : outfitEn;

    String localeTranslate(String key) => outfit[key] ?? key;

    if (condition.isRainy) {
      if (temperature >= 30 && units.isCelsius ||
          temperature >= 86 && units.isFahrenheit) {
        return localeTranslate('outfit.rainy_hot');
      } else {
        return localeTranslate('outfit.rainy');
      }
    } else if (condition.isSnowy) {
      return localeTranslate('outfit.snowy');
    } else if (temperature < 10 && units.isCelsius ||
        temperature < 50 && units.isFahrenheit) {
      return localeTranslate('outfit.cold');
    } else if (temperature >= 10 && temperature < 20 && units.isCelsius ||
        temperature >= 50 && temperature < 68 && units.isFahrenheit) {
      return localeTranslate('outfit.cool');
    } else if (temperature >= 20 && temperature < 30 && units.isCelsius ||
        temperature >= 68 && temperature < 86 && units.isFahrenheit) {
      return localeTranslate('outfit.warm');
    } else if (temperature >= 30 && units.isCelsius ||
        temperature >= 86 && units.isFahrenheit) {
      return localeTranslate('outfit.hot');
    } else {
      return localeTranslate('outfit.moderate');
    }
  }

  Future<String> downloadAndSaveImage(String assetPath) async {
    // Check if the platform is web OR macOS.
    // See issue: https://github.com/ABausG/home_widget/issues/137.
    if (!kIsWeb && !Platform.isMacOS) {
      try {
        // Load asset data as ByteData.
        final ByteData byteData = await rootBundle.load(assetPath);

        // Get the application documents directory.
        final Directory directory = await getAppDirectory();
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
        final String locale = PlatformDispatcher.instance.locale.languageCode;
        throw Exception(
          '${_translateError('error.save_asset_image_failed', locale)}: $e',
        );
      }
    } else {
      return assetPath;
    }
  }

  Future<bool> saveLanguageIsoCode(String languageIsoCode) {
    final bool isSupported = Language.values.any(
      (Language lang) => lang.isoLanguageCode == languageIsoCode,
    );

    final String safeLanguageCode = isSupported
        ? languageIsoCode
        : Language.en.isoLanguageCode;

    return _preferences.setString(
      Settings.languageIsoCode.key,
      safeLanguageCode,
    );
  }

  String getLanguageIsoCode() {
    final String? savedLanguageIsoCode = _preferences.getString(
      Settings.languageIsoCode.key,
    );

    final bool isSavedLanguageSupported =
        savedLanguageIsoCode != null &&
        Language.values.any(
          (Language lang) => lang.isoLanguageCode == savedLanguageIsoCode,
        );

    final String systemLanguageCode =
        PlatformDispatcher.instance.locale.languageCode;

    String defaultLanguageCode =
        Language.values.any(
          (Language lang) => lang.isoLanguageCode == systemLanguageCode,
        )
        ? systemLanguageCode
        : Language.en.isoLanguageCode;

    final String host = Uri.base.host;

    for (final Language language in Language.values) {
      final String currentLanguageCode = language.isoLanguageCode;
      if (host.startsWith('$currentLanguageCode.')) {
        try {
          Intl.defaultLocale = currentLanguageCode;
        } catch (e, stackTrace) {
          debugPrint(
            'Failed to set Intl.defaultLocale to "$currentLanguageCode".\n'
            'Error: $e\n'
            'StackTrace: $stackTrace\n'
            'Proceeding with previously set default locale or system default.',
          );
        }
        defaultLanguageCode = currentLanguageCode;
        // Exit the loop once a match is found and processed.
        break;
      }
    }

    return isSavedLanguageSupported
        ? savedLanguageIsoCode
        : defaultLanguageCode;
  }

  Language getSavedLanguage() {
    final String savedLanguageIsoCode = getLanguageIsoCode();
    final Language savedLanguage = Language.fromIsoLanguageCode(
      savedLanguageIsoCode,
    );
    return savedLanguage;
  }

  Future<bool> saveLocation(Location location) {
    final String json = jsonEncode(location.toJson());
    return _preferences.setString(Settings.location.key, json);
  }

  Location getLastSavedLocation() {
    final String jsonString =
        _preferences.getString(Settings.location.key) ?? '';
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

  Future<Directory> getAppDirectory() async {
    return getApplicationDocumentsDirectory();
  }

  Future<bool> fileExists(String filePath) async {
    return File(filePath).exists();
  }

  String _translateError(String key, String locale) {
    final Map<String, Map<String, String>> localizedErrors =
        <String, Map<String, String>>{
          'error.save_asset_image_failed': <String, String>{
            'en': 'Failed to save asset image',
            'uk': 'Не вдалося зберегти зображення',
          },
        };
    return localizedErrors[key]?[locale] ?? key;
  }
}
