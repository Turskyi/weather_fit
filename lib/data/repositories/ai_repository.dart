import 'package:weather_fit/data/data_sources/remote/remote_data_source.dart';
import 'package:weather_fit/entities/weather.dart';

class AiRepository {
  const AiRepository(this._remoteDataSource);

  final RemoteDataSource _remoteDataSource;

  Future<String> getImageUrlFromAiAsFuture(Weather weather) =>
      _remoteDataSource.getImageUrlFromOpenAiAsFuture(weather);
}
