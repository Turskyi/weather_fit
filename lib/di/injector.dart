import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
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
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    Workmanager()
        .initialize(_callbackDispatcher, isInDebugMode: kDebugMode)
        .then((void _) {
      Workmanager().registerPeriodicTask(
        'weatherfit_background_update',
        'updateWidgetTask',
        // Every 4 hours.
        frequency: const Duration(hours: 4),
        constraints: Constraints(networkType: NetworkType.connected),
      );
    });
  }

  Bloc.observer = const WeatherBlocObserver();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
}

/// Used for Background Updates using Workmanager Plugin.
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((
    String taskName,
    Map<String, Object?>? inputData,
  ) async {
    try {
      // Must initialize Flutter binding.
      WidgetsFlutterBinding.ensureInitialized();

      // Set app group ID.
      HomeWidget.setAppGroupId(constants.appleAppGroupId);

      // Get latest weather.
      final WeatherRepository weatherRepository = WeatherRepository();

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      final LocalDataSource localDataSource = LocalDataSource(preferences);

      final Location lastSavedLocation = localDataSource.getLastSavedLocation();

      final WeatherDomain domainWeather =
          await weatherRepository.getWeatherByLocation(
        lastSavedLocation,
      );

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

      final String outfitRecommendation =
          outfitRepository.getOutfitRecommendation(
        updatedWeather,
      );

      final String outfitAssetPath = outfitRepository.getOutfitImageAssetPath(
        weather,
      );

      final String outfitFilePath = await outfitRepository.downloadAndSaveImage(
        outfitAssetPath,
      );

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

      await HomeWidget.saveWidgetData(
        HomeWidgetKey.textLastUpdated.stringValue,
        '${translate('last_updated_on_label')}\n'
        '${weather.getFormattedLastUpdatedDateTime(
          localDataSource.getLanguageIsoCode(),
        )}',
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
    } catch (e) {
      debugPrint('Background widget update failed: $e');
      return false;
    }
  });
}
