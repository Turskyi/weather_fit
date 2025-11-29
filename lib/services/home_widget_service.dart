import 'package:home_widget/home_widget.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/res/home_widget_keys.dart';

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
    return HomeWidget.updateWidget(iOSName: iOSName, androidName: androidName);
  }

  @override
  Future<void> updateHomeWidget({
    required LocalDataSource localDataSource,
    required Weather weather,
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

    await saveWidgetData<String>(
      HomeWidgetKey.imageWeather.stringValue,
      outfitFilePath,
    );

    // Update the widget.
    await updateWidget(
      iOSName: constants.iOSWidgetName,
      androidName: constants.androidWidgetName,
    );
  }
}
