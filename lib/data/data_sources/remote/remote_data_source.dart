import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;

part 'remote_data_source.g.dart';

@RestApi(baseUrl: constants.kRemoteOutfitBaseUrl)
abstract class RemoteDataSource {
  factory RemoteDataSource(Dio dio, {String baseUrl}) = _RemoteDataSource;

  @GET('{fileName}')
  @DioResponseType(ResponseType.bytes)
  Future<List<int>> downloadOutfitImage(@Path('fileName') String fileName);
}
