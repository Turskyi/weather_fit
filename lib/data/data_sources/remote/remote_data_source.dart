import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'remote_data_source.g.dart';

@RestApi(baseUrl: 'https://raw.githubusercontent.com/Turskyi/weather_fit/refs/heads/dev31/outfits/')
abstract class RemoteDataSource {
  factory RemoteDataSource(Dio dio, {String baseUrl}) = _RemoteDataSource;

  @GET('{fileName}')
  @DioResponseType(ResponseType.bytes)
  Future<List<int>> downloadOutfitImage(@Path('fileName') String fileName);
}
