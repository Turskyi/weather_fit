part of 'weather_bloc.dart';

@immutable
sealed class WeatherState extends Equatable {
  const WeatherState({
    this.outfitRecommendation = '',
    this.outfitAssetPath = '',
    this.message = '',
    Weather? weather,
  }) : weather = weather ?? Weather.empty;

  factory WeatherState.fromJson(Map<String, Object?> json) =>
      _$WeatherSuccessFromJson(json);

  final Weather weather;
  final String outfitRecommendation;
  final String message;
  final String outfitAssetPath;

  @override
  List<Object> get props => <Object>[
        weather,
        outfitRecommendation,
        outfitAssetPath,
        message,
      ];

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'weather': weather.toJson(),
      'outfit_recommendation': outfitRecommendation,
      'outfit_asset_path': outfitAssetPath,
      'message': message,
    };
  }

  Location get location => weather.location;

  String get locationCity => weather.location.name;

  String get locationName => weather.location.locationName;

  bool get needsRefresh => weather.needsRefresh;

  int get remainingMinutes => weather.remainingMinutes;

  String get formattedLastUpdatedDateTime =>
      weather.formattedLastUpdatedDateTime;

  String get formattedTemperature => weather.formattedTemperature;

  String get emoji => weather.emoji;

  TemperatureUnits get temperatureUnits => weather.temperatureUnits;
}

@JsonSerializable()
final class WeatherInitial extends WeatherState {
  const WeatherInitial({
    super.outfitRecommendation,
    super.weather,
    super.outfitAssetPath,
  });

  factory WeatherInitial.fromJson(Map<String, Object?> json) =>
      _$WeatherInitialFromJson(json);

  @override
  Map<String, Object?> toJson() => _$WeatherInitialToJson(this);

  WeatherInitial copyWith({
    Weather? weather,
    String? outfitRecommendation,
    String? outfitAssetPath,
  }) =>
      WeatherInitial(
        weather: weather ?? this.weather,
        outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
        outfitAssetPath: outfitAssetPath ?? this.outfitAssetPath,
      );
}

@JsonSerializable()
class WeatherLoadingState extends WeatherState {
  const WeatherLoadingState({
    super.outfitRecommendation,
    super.weather,
    super.outfitAssetPath,
  });

  factory WeatherLoadingState.fromJson(Map<String, Object?> json) =>
      _$WeatherLoadingStateFromJson(json);

  @override
  Map<String, Object?> toJson() => _$WeatherLoadingStateToJson(this);

  WeatherLoadingState copyWith({
    Weather? weather,
    String? outfitRecommendation,
  }) =>
      WeatherLoadingState(
        weather: weather ?? this.weather,
        outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
      );

  @override
  List<Object> get props => <Object>[
        weather,
        outfitRecommendation,
        outfitAssetPath,
      ];
}

@JsonSerializable()
class WeatherSuccess extends WeatherState {
  const WeatherSuccess({
    super.outfitAssetPath,
    super.outfitRecommendation,
    super.weather,
    super.message,
  });

  factory WeatherSuccess.fromJson(Map<String, Object?> json) =>
      _$WeatherSuccessFromJson(json);

  @override
  Map<String, Object?> toJson() => _$WeatherSuccessToJson(this);

  WeatherSuccess copyWith({
    Weather? weather,
    String? outfitRecommendation,
    String? outfitAssetPath,
    String? message,
  }) =>
      WeatherSuccess(
        weather: weather ?? this.weather,
        outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
        outfitAssetPath: outfitAssetPath ?? this.outfitAssetPath,
        message: message ?? this.message,
      );

  @override
  List<Object> get props => <Object>[
        weather,
        outfitRecommendation,
        outfitAssetPath,
        message,
      ];
}

@JsonSerializable()
final class LoadingOutfitState extends WeatherSuccess {
  const LoadingOutfitState({
    super.outfitRecommendation = '',
    super.outfitAssetPath = '',
    super.weather,
  });

  factory LoadingOutfitState.fromJson(Map<String, Object?> json) =>
      _$LoadingOutfitStateFromJson(json);
}

@JsonSerializable()
class WeatherFailure extends WeatherState {
  const WeatherFailure({
    super.outfitAssetPath,
    super.outfitRecommendation,
    super.message,
  });

  factory WeatherFailure.fromJson(Map<String, Object?> json) =>
      _$WeatherFailureFromJson(json);

  @override
  Map<String, Object?> toJson() => _$WeatherFailureToJson(this);

  @override
  List<Object> get props => <Object>[
        outfitRecommendation,
        outfitAssetPath,
        message,
      ];
}

@JsonSerializable()
class LocalWebCorsFailure extends WeatherFailure {
  const LocalWebCorsFailure({super.outfitRecommendation, super.message});

  factory LocalWebCorsFailure.fromJson(Map<String, Object?> json) =>
      _$LocalWebCorsFailureFromJson(json);

  @override
  Map<String, Object?> toJson() => _$LocalWebCorsFailureToJson(this);

  @override
  List<Object> get props => <Object>[message];
}
