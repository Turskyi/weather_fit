part of 'weather_bloc.dart';

@immutable
sealed class WeatherState extends Equatable {
  const WeatherState({
    this.outfitRecommendation = '',
    this.outfitFilePath = '',
    this.message = '',
    Weather? weather,
  }) : weather = weather ?? Weather.empty;

  factory WeatherState.fromJson(Map<String, Object?> json) =>
      _$WeatherSuccessFromJson(json);

  final Weather weather;
  final String outfitRecommendation;
  final String message;
  final String outfitFilePath;

  @override
  List<Object> get props => <Object>[
        weather,
        outfitRecommendation,
        outfitFilePath,
        message,
      ];

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'weather': weather.toJson(),
      'outfit_recommendation': outfitRecommendation,
      'outfit_file_path': outfitFilePath,
      'message': message,
    };
  }

  String get location => weather.city;

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
    super.outfitFilePath,
  });

  factory WeatherInitial.fromJson(Map<String, Object?> json) =>
      _$WeatherInitialFromJson(json);

  @override
  Map<String, Object?> toJson() => _$WeatherInitialToJson(this);

  WeatherInitial copyWith({
    Weather? weather,
    String? outfitRecommendation,
    String? outfitFilePath,
  }) =>
      WeatherInitial(
        weather: weather ?? this.weather,
        outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
        outfitFilePath: outfitFilePath ?? this.outfitFilePath,
      );
}

@JsonSerializable()
class WeatherLoadingState extends WeatherState {
  const WeatherLoadingState({
    super.outfitRecommendation,
    super.weather,
    super.outfitFilePath,
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
        outfitFilePath,
      ];
}

@JsonSerializable()
class WeatherSuccess extends WeatherState {
  const WeatherSuccess({
    super.outfitFilePath,
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
    String? outfitFilePath,
    String? message,
  }) =>
      WeatherSuccess(
        weather: weather ?? this.weather,
        outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
        outfitFilePath: outfitFilePath ?? this.outfitFilePath,
        message: message ?? this.message,
      );

  @override
  List<Object> get props => <Object>[
        weather,
        outfitRecommendation,
        outfitFilePath,
        message,
      ];
}

@JsonSerializable()
final class LoadingOutfitState extends WeatherSuccess {
  const LoadingOutfitState({
    super.outfitRecommendation = '',
    super.outfitFilePath = '',
    super.weather,
  });

  factory LoadingOutfitState.fromJson(Map<String, Object?> json) =>
      _$LoadingOutfitStateFromJson(json);
}

@JsonSerializable()
class WeatherFailure extends WeatherState {
  const WeatherFailure({
    super.outfitFilePath,
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
        outfitFilePath,
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
