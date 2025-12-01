part of 'weather_bloc.dart';

@immutable
sealed class WeatherState extends Equatable {
  const WeatherState({
    required this.locale,
    this.outfitRecommendation = '',
    this.outfitAssetPath = '',
    this.message = '',
    this.dailyForecast,
    Weather? weather,
  }) : weather = weather ?? Weather.empty;

  factory WeatherState.fromJson(Map<String, Object?> json) {
    return _$WeatherSuccessFromJson(json);
  }

  final Weather weather;
  final String outfitRecommendation;
  final String message;
  final String outfitAssetPath;
  final String locale;
  final DailyForecastDomain? dailyForecast;

  @override
  List<Object?> get props => <Object?>[
    weather,
    outfitRecommendation,
    outfitAssetPath,
    message,
    locale,
    isCelsius,
    dailyForecast,
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

  String get formattedLastUpdatedDateTime {
    return weather.getFormattedLastUpdatedDateTime(locale);
  }

  String get formattedTemperature => weather.formattedTemperature;

  String get emoji => weather.emoji;

  TemperatureUnits get temperatureUnits => weather.temperatureUnits;

  bool get isCelsius => weather.temperatureUnits.isCelsius;

  bool get isNotLoading =>
      this is! LoadingOutfitState && this is! WeatherLoadingState;

  bool get isInitial => this is WeatherInitial;
}

@JsonSerializable()
final class WeatherInitial extends WeatherState {
  const WeatherInitial({
    required super.locale,
    super.outfitRecommendation,
    super.weather,
    super.outfitAssetPath,
    super.dailyForecast,
  });

  factory WeatherInitial.fromJson(Map<String, Object?> json) {
    return _$WeatherInitialFromJson(json);
  }

  @override
  Map<String, Object?> toJson() => _$WeatherInitialToJson(this);

  WeatherInitial copyWith({
    String? locale,
    Weather? weather,
    String? outfitRecommendation,
    String? outfitAssetPath,
    DailyForecastDomain? dailyForecast,
    Language? language,
  }) {
    return WeatherInitial(
      locale: locale ?? this.locale,
      weather: weather ?? this.weather,
      outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
      outfitAssetPath: outfitAssetPath ?? this.outfitAssetPath,
      dailyForecast: dailyForecast ?? this.dailyForecast,
    );
  }
}

@JsonSerializable()
class WeatherLoadingState extends WeatherState {
  const WeatherLoadingState({
    required super.locale,
    required super.weather,
    super.outfitRecommendation,
    super.outfitAssetPath,
    super.dailyForecast,
  });

  factory WeatherLoadingState.fromJson(Map<String, Object?> json) =>
      _$WeatherLoadingStateFromJson(json);

  @override
  Map<String, Object?> toJson() => _$WeatherLoadingStateToJson(this);

  WeatherLoadingState copyWith({
    String? locale,
    Weather? weather,
    String? outfitRecommendation,
    DailyForecastDomain? dailyForecast,
  }) => WeatherLoadingState(
    locale: locale ?? this.locale,
    weather: weather ?? this.weather,
    outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
    dailyForecast: dailyForecast ?? this.dailyForecast,
  );

  @override
  List<Object?> get props => <Object?>[
    locale,
    weather,
    outfitRecommendation,
    outfitAssetPath,
    dailyForecast,
  ];
}

@JsonSerializable()
class WeatherSuccess extends WeatherState {
  const WeatherSuccess({
    required super.locale,
    required super.dailyForecast,
    super.outfitAssetPath,
    super.outfitRecommendation,
    super.weather,
    super.message,
  });

  factory WeatherSuccess.fromJson(Map<String, Object?> json) {
    return _$WeatherSuccessFromJson(json);
  }

  @override
  Map<String, Object?> toJson() => _$WeatherSuccessToJson(this);

  WeatherSuccess copyWith({
    String? locale,
    Weather? weather,
    String? outfitRecommendation,
    String? outfitAssetPath,
    String? message,
    DailyForecastDomain? dailyForecast,
  }) => WeatherSuccess(
    locale: locale ?? this.locale,
    weather: weather ?? this.weather,
    outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
    outfitAssetPath: outfitAssetPath ?? this.outfitAssetPath,
    message: message ?? this.message,
    dailyForecast: dailyForecast ?? this.dailyForecast,
  );

  @override
  List<Object?> get props => <Object?>[
    locale,
    weather,
    outfitRecommendation,
    outfitAssetPath,
    message,
    dailyForecast,
  ];
}

@JsonSerializable()
final class LoadingOutfitState extends WeatherSuccess {
  const LoadingOutfitState({
    required super.locale,
    required super.dailyForecast,
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
    required super.locale,
    super.outfitAssetPath,
    super.outfitRecommendation,
    super.message,
    super.dailyForecast,
  });

  factory WeatherFailure.fromJson(Map<String, Object?> json) {
    return _$WeatherFailureFromJson(json);
  }

  @override
  Map<String, Object?> toJson() => _$WeatherFailureToJson(this);

  @override
  List<Object?> get props => <Object?>[
    locale,
    outfitRecommendation,
    outfitAssetPath,
    message,
    dailyForecast,
  ];
}

@JsonSerializable()
class LocalWebCorsFailure extends WeatherFailure {
  const LocalWebCorsFailure({
    required super.locale,
    super.outfitRecommendation,
    super.message,
    super.dailyForecast,
  });

  factory LocalWebCorsFailure.fromJson(Map<String, Object?> json) {
    return _$LocalWebCorsFailureFromJson(json);
  }

  @override
  Map<String, Object?> toJson() => _$LocalWebCorsFailureToJson(this);

  @override
  List<Object?> get props => <Object?>[locale, message, dailyForecast];
}
