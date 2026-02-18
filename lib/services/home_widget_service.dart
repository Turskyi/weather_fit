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

  Future<void> requestPinWidget({
    String? name,
    String? androidName,
    String? qualifiedAndroidName,
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

    final List<String> outfitFilePaths = await outfitRepository
        .downloadAndSaveImages(weather);

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

    // Save weather code for background color mapping.
    await saveWidgetData<int>(
      HomeWidgetKey.weatherCode.stringValue,
      weather.code,
    );

    // The image feature is temporarily disabled.
    // For now, we take the first path if multiple are available.
    await saveWidgetData<String>(
      HomeWidgetKey.imageWeather.stringValue,
      outfitFilePaths.firstOrNull ?? '',
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

  @override
  Future<void> requestPinWidget({
    String? name,
    String? androidName,
    String? qualifiedAndroidName,
  }) {
    return HomeWidget.requestPinWidget(
      name: name,
      androidName: androidName,
      qualifiedAndroidName: qualifiedAndroidName,
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
      final List<ForecastItemDomain> result = <ForecastItemDomain?>[
        morning,
        lunch,
        evening,
      ].whereType<ForecastItemDomain>().toList();

      // 4. Sort by time to ensure chronological order.
      result.sort(
        (ForecastItemDomain a, ForecastItemDomain b) =>
            a.time.compareTo(b.time),
      );

      return result;
    } else {
      return <ForecastItemDomain>[];
    }
  }
}
