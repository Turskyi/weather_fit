import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:home_widget/home_widget.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/res/home_widget_keys.dart';
import 'package:weather_repository/weather_repository.dart';

abstract class HomeWidgetService {
  const HomeWidgetService();

  Future<void> setAppGroupId(String appGroupId);

  Future<bool?> saveWidgetData<T>(String id, T? data);

  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  });

  Future<void> updateHomeWidget({
    required LocalDataSource localDataSource,
    required Weather weather,
    required DailyForecastDomain forecast,
    required OutfitRepository outfitRepository,
  });
}

class HomeWidgetServiceImpl implements HomeWidgetService {
  const HomeWidgetServiceImpl();

  @override
  Future<void> setAppGroupId(String appGroupId) {
    return HomeWidget.setAppGroupId(appGroupId);
  }

  @override
  Future<bool?> saveWidgetData<T>(String id, T? data) {
    return HomeWidget.saveWidgetData<T>(id, data);
  }

  @override
  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) {
    return HomeWidget.updateWidget(
      name: name,
      iOSName: iOSName,
      androidName: androidName,
      qualifiedAndroidName: qualifiedAndroidName,
    );
  }

  @override
  Future<void> updateHomeWidget({
    required LocalDataSource localDataSource,
    required Weather weather,
    required DailyForecastDomain forecast,
    required OutfitRepository outfitRepository,
  }) async {
    final String savedLanguageIsoCode = localDataSource.getLanguageIsoCode();

    final TemperatureUnits units = weather.temperatureUnits;

    final double temperatureValue = units.isFahrenheit
        ? weather.temperature.value.toFahrenheit()
        : weather.temperature.value;

    final Weather updatedWeather = weather.copyWith(
      temperature: Temperature(value: temperatureValue),
      temperatureUnits: units,
    );

    final String outfitRecommendation = outfitRepository
        .getOutfitRecommendation(updatedWeather);

    final String outfitAssetPath = outfitRepository.getOutfitImageAssetPath(
      weather,
    );
    final String outfitFilePath = await outfitRepository.downloadAndSaveImage(
      outfitAssetPath,
    );

    // Set app group ID.
    await setAppGroupId(constants.appleAppGroupId);

    await saveWidgetData<String>(
      HomeWidgetKey.textLastUpdated.stringValue,
      weather.getFormattedLastUpdatedDateTime(savedLanguageIsoCode),
    );

    // Save data.
    await saveWidgetData<String>(
      HomeWidgetKey.textEmoji.stringValue,
      weather.emoji,
    );

    await saveWidgetData<String>(
      HomeWidgetKey.textLocation.stringValue,
      weather.locationName,
    );

    await saveWidgetData<String>(
      HomeWidgetKey.textTemperature.stringValue,
      weather.formattedTemperature,
    );

    await saveWidgetData<String>(
      HomeWidgetKey.textRecommendation.stringValue,
      outfitRecommendation,
    );

    // The image feature is temporarily disabled.
    await saveWidgetData<String>(
      HomeWidgetKey.imageWeather.stringValue,
      outfitFilePath,
    );

    // Filter the forecast to send only the data the widget needs.
    final DailyForecastDomain filteredForecast = DailyForecastDomain(
      forecast: _filterForecastForWidget(forecast.forecast),
    );
    final String forecastData = jsonEncode(filteredForecast.toJson());

    await saveWidgetData<String>(
      HomeWidgetKey.forecastData.stringValue,
      forecastData,
    );

    // Update the widget.
    await updateWidget(
      iOSName: constants.iOSWidgetName,
      androidName: constants.androidWidgetName,
    );
  }

  /// Filters the full forecast list to a few essential time points for the
  /// widget to avoid exceeding data size limits for `saveWidgetData`.
  List<ForecastItemDomain> _filterForecastForWidget(
    List<ForecastItemDomain> fullForecast,
  ) {
    if (fullForecast.isNotEmpty) {
      final DateTime now = DateTime.now();
      // 1. Get all forecasts that are in the future.
      final List<ForecastItemDomain> futureForecasts = fullForecast.where((
        ForecastItemDomain item,
      ) {
        final DateTime? itemDate = DateTime.tryParse(item.time);
        return itemDate != null && itemDate.isAfter(now);
      }).toList();

      // 2. Find the first available item for each time slot.
      final ForecastItemDomain? morning = futureForecasts.firstWhereOrNull(
        (ForecastItemDomain item) =>
            DateTime.parse(item.time).hour >= 8 &&
            DateTime.parse(item.time).hour <= 11,
      );
      final ForecastItemDomain? lunch = futureForecasts.firstWhereOrNull(
        (ForecastItemDomain item) =>
            DateTime.parse(item.time).hour >= 12 &&
            DateTime.parse(item.time).hour <= 15,
      );
      final ForecastItemDomain? evening = futureForecasts.firstWhereOrNull(
        (ForecastItemDomain item) =>
            DateTime.parse(item.time).hour >= 17 &&
            DateTime.parse(item.time).hour <= 20,
      );

      // 3. Build the result list, removing any nulls.
      final List<ForecastItemDomain> result =
          <ForecastItemDomain?>[morning, lunch, evening]
              .where((ForecastItemDomain? item) => item != null)
              .cast<ForecastItemDomain>()
              .toList();

      return result;
    } else {
      return <ForecastItemDomain>[];
    }
  }
}
