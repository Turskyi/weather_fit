import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart';

abstract class HomeWidgetService {
  const HomeWidgetService();

  Future<void> setAppGroupId(String appGroupId);

  /// Save [data] to the Widget Storage
  ///
  /// Returns whether the data was saved or not
  Future<bool?> saveWidgetData<T>(String id, T? data);

  /// Updates the HomeScreen Widget
  ///
  /// Android Widgets will look for [qualifiedAndroidName] then [androidName]
  /// and then for [name] iOS Widgets will look for [iOSName] and then for
  /// [name].
  ///
  /// [qualifiedAndroidName] will use the name as is to find the
  /// `WidgetProvider` [androidName] must match the classname of the
  /// `WidgetProvider`, prefixed by the package name
  /// The name of the iOS Widget must match the kind specified when creating
  /// the Widget
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
