part of 'weather_bloc.dart';

@immutable
sealed class WeatherState extends Equatable {
  const WeatherState({
    this.outfitImageUrl = '',
    this.message = '',
    Weather? weather,
  }) : weather = weather ?? Weather.empty;

  final Weather weather;
  final String outfitImageUrl;
  final String message;

  @override
  List<Object> get props => <Object>[weather, outfitImageUrl, message];
}

@JsonSerializable()
final class WeatherInitial extends WeatherState {
  const WeatherInitial({super.weather});

  factory WeatherInitial.fromJson(Map<String, dynamic> json) =>
      _$WeatherInitialFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherInitialToJson(this);

  WeatherInitial copyWith({Weather? weather}) =>
      WeatherInitial(weather: weather ?? this.weather);
}

@JsonSerializable()
class WeatherLoadingState extends WeatherState {
  const WeatherLoadingState({super.weather, super.outfitImageUrl = ''});

  factory WeatherLoadingState.fromJson(Map<String, dynamic> json) =>
      _$WeatherLoadingStateFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherLoadingStateToJson(this);

  WeatherLoadingState copyWith({
    Weather? weather,
    String? outfitImageUrl,
  }) =>
      WeatherLoadingState(
        weather: weather ?? this.weather,
        outfitImageUrl: outfitImageUrl ?? this.outfitImageUrl,
      );

  @override
  List<Object> get props => <Object>[weather, outfitImageUrl];
}

@JsonSerializable()
class WeatherSuccess extends WeatherState {
  const WeatherSuccess({super.weather, super.outfitImageUrl = ''});

  factory WeatherSuccess.fromJson(Map<String, dynamic> json) =>
      _$WeatherSuccessFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherSuccessToJson(this);

  WeatherSuccess copyWith({
    Weather? weather,
    String? outfitImageUrl,
  }) =>
      WeatherSuccess(
        weather: weather ?? this.weather,
        outfitImageUrl: outfitImageUrl ?? this.outfitImageUrl,
      );

  @override
  List<Object> get props => <Object>[weather, outfitImageUrl];
}

@JsonSerializable()
final class LoadingOutfitState extends WeatherSuccess {
  const LoadingOutfitState({super.weather, super.outfitImageUrl = ''});

  factory LoadingOutfitState.fromJson(Map<String, dynamic> json) =>
      _$LoadingOutfitStateFromJson(json);
}

@JsonSerializable()
class WeatherFailure extends WeatherState {
  const WeatherFailure({super.message});

  factory WeatherFailure.fromJson(Map<String, dynamic> json) =>
      _$WeatherFailureFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherFailureToJson(this);

  @override
  List<Object> get props => <Object>[message];
}
