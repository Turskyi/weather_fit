import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/res/home_widget_keys.dart';
import 'package:weather_fit/weather_bloc_observer.dart';
import 'package:weather_repository/weather_repository.dart';
import 'package:workmanager/workmanager.dart';

Future<void> injectDependencies() async {
  await _initializeAllDateFormatting();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      Workmanager()
          .initialize(_callbackDispatcher, isInDebugMode: kDebugMode)
          .then((void _) {
            try {
              Workmanager().registerPeriodicTask(
                'weatherfit_background_update',
                'updateWidgetTask',
                // Home widget will be updated every two hours.
                frequency: const Duration(minutes: 120),
                constraints: Constraints(networkType: NetworkType.connected),
              );
            } catch (e) {
              debugPrint(
                'Background widget update failed in '
                'Workmanager.registerPeriodicTask: $e',
              );
            }
          });
    } catch (e) {
      debugPrint(
        'Background widget update failed in Workmanager.initialize: $e',
      );
    }
  }

  Bloc.observer = const WeatherBlocObserver();

  if (kIsWeb) {
    try {
      final HydratedStorage hydratedStorage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory.web,
      );
      HydratedBloc.storage = hydratedStorage;
    } catch (e) {
      debugPrint('Failed to initialize hydrated storage on web: $e');
    }
  } else {
    try {
      // We cannot specify `Directory` type here, otherwise it will not work on
      // Web.
      final dynamic temporaryDirectory = await getTemporaryDirectory();
      final HydratedStorage hydratedStorage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory(temporaryDirectory.path),
      );
      HydratedBloc.storage = hydratedStorage;
    } catch (e) {
      debugPrint('Failed to initialize hydrated storage: $e');
    }
  }
}

/// Used for Background Updates using [Workmanager] Plugin.
@pragma('vm:entry-point')
void _callbackDispatcher() {
  try {
    Workmanager().executeTask((String _, Map<String, Object?>? _) async {
      try {
        WidgetsFlutterBinding.ensureInitialized();

        await _initializeAllDateFormatting();

        // Set app group ID.
        await HomeWidget.setAppGroupId(constants.appleAppGroupId);

        // Get latest weather.
        final WeatherRepository weatherRepository = WeatherRepository();

        final SharedPreferences preferences =
            await SharedPreferences.getInstance();

        final LocalDataSource localDataSource = LocalDataSource(preferences);

        final Location lastSavedLocation = localDataSource
            .getLastSavedLocation();

        if (lastSavedLocation.isNotEmpty) {
          final WeatherDomain domainWeather = await weatherRepository
              .getWeatherByLocation(lastSavedLocation);
          final Weather weather = Weather.fromRepository(domainWeather);

          final TemperatureUnits units = weather.temperatureUnits;

          final double temperatureValue = units.isFahrenheit
              ? weather.temperature.value.toFahrenheit()
              : weather.temperature.value;

          final Weather updatedWeather = weather.copyWith(
            temperature: Temperature(value: temperatureValue),
            temperatureUnits: units,
          );

          final OutfitRepository outfitRepository = OutfitRepository(
            localDataSource,
          );

          final String outfitRecommendation = outfitRepository
              .getOutfitRecommendation(updatedWeather);

          final String outfitAssetPath = outfitRepository
              .getOutfitImageAssetPath(weather);

          final String outfitFilePath = await outfitRepository
              .downloadAndSaveImage(outfitAssetPath);

          // Save data.
          await HomeWidget.saveWidgetData(
            HomeWidgetKey.textEmoji.stringValue,
            weather.condition.toEmoji,
          );

          await HomeWidget.saveWidgetData(
            HomeWidgetKey.textLocation.stringValue,
            weather.locationName,
          );

          await HomeWidget.saveWidgetData(
            HomeWidgetKey.textTemperature.stringValue,
            weather.formattedTemperature,
          );

          await HomeWidget.saveWidgetData(
            HomeWidgetKey.textRecommendation.stringValue,
            outfitRecommendation,
          );

          final String savedLanguageIsoCode = localDataSource
              .getLanguageIsoCode();

          await HomeWidget.saveWidgetData(
            HomeWidgetKey.textLastUpdated.stringValue,
            weather.getFormattedLastUpdatedDateTime(savedLanguageIsoCode),
          );

          await HomeWidget.saveWidgetData(
            HomeWidgetKey.imageWeather.stringValue,
            outfitFilePath,
          );

          // Update the widget.
          await HomeWidget.updateWidget(
            iOSName: constants.iOSWidgetName,
            androidName: constants.androidWidgetName,
          );
          return true;
        } else {
          return false;
        }
      } catch (e) {
        debugPrint('Background widget update failed: $e');
        return false;
      }
    });
  } catch (e) {
    debugPrint('Error while WorkManager.executeTask: $e');
  }
}

Future<void> _initializeAllDateFormatting() async {
  for (Language lang in Language.values) {
    try {
      await initializeDateFormatting(lang.isoLanguageCode, null);
    } catch (e, stackTrace) {
      debugPrint(
        'Failed to initialize date formatting for ${lang.isoLanguageCode}.\n'
        'Error: $e\n'
        'StackTrace: $stackTrace',
      );
    }
  }
}

/// Called when Doing Background Work initiated from Widget
@pragma('vm:entry-point')
Future<void> _interactiveCallback(Uri? data) async {
  //TODO: add implementation.
}
