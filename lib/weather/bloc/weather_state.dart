part of 'weather_bloc.dart';

@immutable
sealed class WeatherState extends Equatable {
  const WeatherState({
    required this.locale,
    required this.date,
    this.outfitRecommendation = '',
    this.outfitImage = const OutfitImage.empty(),
    this.message = '',
    this.dailyForecast,
    this.isFavourite = false,
    Weather? weather,
  }) : weather = weather ?? Weather.empty;

  factory WeatherState.fromJson(Map<String, Object?> json) {
    return _$WeatherSuccessFromJson(json);
  }

  final Weather weather;
  final String outfitRecommendation;
  final String message;
  final OutfitImage outfitImage;
  final String locale;
  final DateTime date;
  final DailyForecastDomain? dailyForecast;
  final bool isFavourite;

  @override
  List<Object?> get props => <Object?>[
    weather,
    outfitRecommendation,
    outfitImage,
    message,
    locale,
    date,
    dailyForecast,
    isFavourite,
  ];

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'weather': weather.toJson(),
      'outfit_recommendation': outfitRecommendation,
      'outfit_image': outfitImage.toJson(),
      'message': message,
      'is_favourite': isFavourite,
      'locale': locale,
      'date': date.toIso8601String(),
      'dailyForecast': dailyForecast?.toJson(),
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

  List<ForecastItemDomain> get forecast {
    final List<ForecastItemDomain> forecastItems =
        dailyForecast?.forecast ?? <ForecastItemDomain>[];

    final DateTime now = DateTime.now();
    const List<int> desiredHours = <int>[8, 13, 19];

    final List<ForecastItemDomain> forecast = forecastItems
        .where((ForecastItemDomain item) {
          final DateTime? itemTime = DateTime.tryParse(item.time);
          return itemTime != null &&
              itemTime.isAfter(now) &&
              desiredHours.contains(itemTime.hour);
        })
        .take(3)
        .toList();
    return forecast;
  }
}

@JsonSerializable()
final class WeatherInitial extends WeatherState {
  const WeatherInitial({
    required super.locale,
    required super.dailyForecast,
    required super.date,
    super.outfitRecommendation,
    super.weather,
    super.outfitImage,
    super.isFavourite,
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
    OutfitImage? outfitImage,
    DailyForecastDomain? dailyForecast,
    Language? language,
    DateTime? date,
    bool? isFavourite,
  }) {
    return WeatherInitial(
      locale: locale ?? this.locale,
      weather: weather ?? this.weather,
      outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
      outfitImage: outfitImage ?? this.outfitImage,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      date: date ?? this.date,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}

@JsonSerializable()
class WeatherLoadingState extends WeatherState {
  const WeatherLoadingState({
    required super.locale,
    required super.weather,
    required super.date,
    super.outfitRecommendation,
    super.outfitImage,
    super.dailyForecast,
    super.isFavourite,
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
    DateTime? date,
    bool? isFavourite,
  }) {
    return WeatherLoadingState(
      locale: locale ?? this.locale,
      weather: weather ?? this.weather,
      outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      date: date ?? this.date,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    locale,
    weather,
    outfitRecommendation,
    outfitImage,
    dailyForecast,
    isFavourite,
    date,
  ];
}

@JsonSerializable()
class WeatherSuccess extends WeatherState {
  const WeatherSuccess({
    required super.locale,
    required super.dailyForecast,
    required super.date,
    super.outfitImage,
    super.outfitRecommendation,
    super.weather,
    super.message,
    super.isFavourite,
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
    OutfitImage? outfitImage,
    String? message,
    DailyForecastDomain? dailyForecast,
    DateTime? date,
    bool? isFavourite,
  }) {
    return WeatherSuccess(
      locale: locale ?? this.locale,
      weather: weather ?? this.weather,
      outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
      outfitImage: outfitImage ?? this.outfitImage,
      message: message ?? this.message,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      date: date ?? this.date,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    locale,
    weather,
    outfitRecommendation,
    outfitImage,
    message,
    dailyForecast,
    isFavourite,
    date,
  ];
}

@JsonSerializable()
final class LoadingOutfitState extends WeatherSuccess {
  const LoadingOutfitState({
    required super.locale,
    required super.dailyForecast,
    required super.date,
    super.outfitRecommendation = '',
    super.outfitImage = const OutfitImage.empty(),
    super.weather,
    super.isFavourite,
  });

  factory LoadingOutfitState.fromJson(Map<String, Object?> json) =>
      _$LoadingOutfitStateFromJson(json);
}

@JsonSerializable()
class WeatherFailure extends WeatherState {
  const WeatherFailure({
    required super.locale,
    required super.date,
    super.weather,
    super.outfitImage,
    super.outfitRecommendation,
    super.message,
    super.dailyForecast,
    super.isFavourite,
  });

  factory WeatherFailure.fromJson(Map<String, Object?> json) {
    return _$WeatherFailureFromJson(json);
  }

  @override
  Map<String, Object?> toJson() => _$WeatherFailureToJson(this);

  @override
  String toString() {
    return '${toJson()}';
  }

  WeatherFailure copyWith({
    String? locale,
    DateTime? date,
    Weather? weather,
    OutfitImage? outfitImage,
    String? outfitRecommendation,
    String? message,
    DailyForecastDomain? dailyForecast,
    bool? isFavourite,
  }) {
    return WeatherFailure(
      locale: locale ?? this.locale,
      date: date ?? this.date,
      weather: weather ?? this.weather,
      outfitImage: outfitImage ?? this.outfitImage,
      outfitRecommendation: outfitRecommendation ?? this.outfitRecommendation,
      message: message ?? this.message,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    locale,
    weather,
    outfitRecommendation,
    outfitImage,
    message,
    dailyForecast,
    isFavourite,
    date,
  ];
}

@JsonSerializable()
class LocalWebCorsFailure extends WeatherFailure {
  const LocalWebCorsFailure({
    required super.locale,
    required super.date,
    super.weather,
    super.outfitRecommendation,
    super.message,
    super.dailyForecast,
    super.isFavourite,
  });

  factory LocalWebCorsFailure.fromJson(Map<String, Object?> json) {
    return _$LocalWebCorsFailureFromJson(json);
  }

  @override
  Map<String, Object?> toJson() => _$LocalWebCorsFailureToJson(this);

  @override
  List<Object?> get props => <Object?>[
    locale,
    weather,
    message,
    dailyForecast,
    isFavourite,
    date,
  ];
}
