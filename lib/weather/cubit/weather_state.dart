part of 'weather_cubit.dart';

@JsonSerializable()
final class WeatherState extends Equatable {
  WeatherState({
    this.outfitImageUrl = '',
    this.status = WeatherStatus.loading,
    Weather? weather,
  }) : weather = weather ?? Weather.empty;

  factory WeatherState.fromJson(Map<String, dynamic> json) =>
      _$WeatherStateFromJson(json);

  final WeatherStatus status;
  final Weather weather;
  final String outfitImageUrl;

  WeatherState copyWith({
    WeatherStatus? status,
    Weather? weather,
    String? outfitImageUrl,
  }) =>
      WeatherState(
        status: status ?? this.status,
        weather: weather ?? this.weather,
        outfitImageUrl: outfitImageUrl ?? this.outfitImageUrl,
      );

  Map<String, dynamic> toJson() => _$WeatherStateToJson(this);

  @override
  List<Object> get props => <Object>[status, weather, outfitImageUrl];
}
