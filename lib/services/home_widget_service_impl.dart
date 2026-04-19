import 'dart:convert' as convert;
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/res/home_widget_keys.dart';
import 'package:weather_fit/services/home_widget_service.dart';
import 'package:weather_repository/weather_repository.dart';

class HomeWidgetServiceImpl implements HomeWidgetService {
  const HomeWidgetServiceImpl();

  static const MethodChannel _widgetChannel = MethodChannel(
    'com.weatherfit.home_widget',
  );
  static const String _appGroupIdArgKey = 'appGroupId';

  @override
  Future<void> setAppGroupId(String appGroupId) {
    if (kIsWeb) {
      return Future<void>.value();
    }
    if (Platform.isMacOS) {
      debugPrint(
        'HomeWidgetService setAppGroupId: macOS channel call '
        '(appGroupId=$appGroupId).',
      );
      return _widgetChannel.invokeMethod<void>(
        'setAppGroupId',
        <String, String>{_appGroupIdArgKey: appGroupId},
      );
    }
    return HomeWidget.setAppGroupId(appGroupId);
  }

  @override
  Future<bool?> saveWidgetData<T>(String id, T? data) {
    if (kIsWeb) {
      return Future<bool>.value(false);
    }
    if (Platform.isMacOS) {
      debugPrint(
        'HomeWidgetService saveWidgetData: macOS channel call '
        '(key=$id, type=${data.runtimeType}).',
      );
      return _widgetChannel.invokeMethod<bool>(
        'saveWidgetData',
        <String, Object?>{
          'key': id,
          'value': data,
          _appGroupIdArgKey: constants.kAppleAppGroupId,
        },
      );
    }
    return HomeWidget.saveWidgetData<T>(id, data);
  }

  @override
  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) {
    if (kIsWeb) {
      return Future<bool>.value(false);
    }
    if (Platform.isMacOS) {
      debugPrint('HomeWidgetService updateWidget: macOS channel call.');
      return _widgetChannel.invokeMethod<bool>('updateWidget');
    }
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
    debugPrint(
      'HomeWidgetService updateHomeWidget: start '
      '(location=${weather.location}, '
      'forecastItems=${forecast.forecast.length}).',
    );
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
    await setAppGroupId(constants.kAppleAppGroupId);

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

    await saveWidgetData<double>(
      HomeWidgetKey.locationLatitude.stringValue,
      weather.location.latitude,
    );

    await saveWidgetData<double>(
      HomeWidgetKey.locationLongitude.stringValue,
      weather.location.longitude,
    );

    await saveWidgetData<String>(
      HomeWidgetKey.temperatureUnit.stringValue,
      weather.temperatureUnits.name,
    );

    await saveWidgetData<int>(
      HomeWidgetKey.widgetUpdateFrequency.stringValue,
      localDataSource.getWidgetUpdateFrequency(),
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

    await saveWidgetData<bool>(
      HomeWidgetKey.isWeatherBackgroundEnabled.stringValue,
      localDataSource.isWeatherBackgroundEnabled(),
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
    final String forecastData = convert.jsonEncode(filteredForecast.toJson());

    await saveWidgetData<String>(
      HomeWidgetKey.forecastData.stringValue,
      forecastData,
    );

    // Update the widget.
    await updateWidget(
      iOSName: constants.kIosWidgetName,
      androidName: constants.kAndroidWidgetName,
    );

    debugPrint('HomeWidgetService updateHomeWidget: completed.');
  }

  @override
  Future<void> requestPinWidget({
    String? name,
    String? androidName,
    String? qualifiedAndroidName,
  }) {
    // macOS widgets in Notification Center don't have a "pin" mechanism.
    // The user must add the widget manually from Notification Center settings.
    if (kIsWeb || Platform.isMacOS) {
      return Future<void>.value();
    }
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
      result.sort((ForecastItemDomain a, ForecastItemDomain b) {
        return a.time.compareTo(b.time);
      });

      return result;
    } else {
      return <ForecastItemDomain>[];
    }
  }
}
