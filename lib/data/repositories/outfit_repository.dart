import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';

class OutfitRepository {
  const OutfitRepository(this._localDataSource);

  final LocalDataSource _localDataSource;

  String getOutfitImageAssetPath(Weather weather) {
    return _localDataSource.getOutfitImageAssetPath(weather);
  }
}
