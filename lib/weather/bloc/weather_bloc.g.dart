// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherInitial _$WeatherInitialFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherInitial',
      json,
      ($checkedConvert) {
        final val = WeatherInitial(
          locale: $checkedConvert('locale', (v) => v as String),
          outfitRecommendation: $checkedConvert(
            'outfit_recommendation',
            (v) => v as String? ?? '',
          ),
          weather: $checkedConvert(
            'weather',
            (v) =>
                v == null ? null : Weather.fromJson(v as Map<String, dynamic>),
          ),
          outfitImage: $checkedConvert(
            'outfit_image',
            (v) => v == null
                ? const OutfitImage.empty()
                : OutfitImage.fromJson(v as Map<String, dynamic>),
          ),
          dailyForecast: $checkedConvert(
            'daily_forecast',
            (v) => v == null
                ? null
                : DailyForecastDomain.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'outfitRecommendation': 'outfit_recommendation',
        'outfitImage': 'outfit_image',
        'dailyForecast': 'daily_forecast',
      },
    );

Map<String, dynamic> _$WeatherInitialToJson(WeatherInitial instance) =>
    <String, dynamic>{
      'weather': instance.weather.toJson(),
      'outfit_recommendation': instance.outfitRecommendation,
      'outfit_image': instance.outfitImage.toJson(),
      'locale': instance.locale,
      'daily_forecast': instance.dailyForecast?.toJson(),
    };

WeatherLoadingState _$WeatherLoadingStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherLoadingState',
      json,
      ($checkedConvert) {
        final val = WeatherLoadingState(
          locale: $checkedConvert('locale', (v) => v as String),
          weather: $checkedConvert(
            'weather',
            (v) =>
                v == null ? null : Weather.fromJson(v as Map<String, dynamic>),
          ),
          outfitRecommendation: $checkedConvert(
            'outfit_recommendation',
            (v) => v as String? ?? '',
          ),
          outfitImage: $checkedConvert(
            'outfit_image',
            (v) => v == null
                ? const OutfitImage.empty()
                : OutfitImage.fromJson(v as Map<String, dynamic>),
          ),
          dailyForecast: $checkedConvert(
            'daily_forecast',
            (v) => v == null
                ? null
                : DailyForecastDomain.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'outfitRecommendation': 'outfit_recommendation',
        'outfitImage': 'outfit_image',
        'dailyForecast': 'daily_forecast',
      },
    );

Map<String, dynamic> _$WeatherLoadingStateToJson(
  WeatherLoadingState instance,
) => <String, dynamic>{
  'weather': instance.weather.toJson(),
  'outfit_recommendation': instance.outfitRecommendation,
  'outfit_image': instance.outfitImage.toJson(),
  'locale': instance.locale,
  'daily_forecast': instance.dailyForecast?.toJson(),
};

WeatherSuccess _$WeatherSuccessFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherSuccess',
      json,
      ($checkedConvert) {
        final val = WeatherSuccess(
          locale: $checkedConvert('locale', (v) => v as String),
          dailyForecast: $checkedConvert(
            'daily_forecast',
            (v) => v == null
                ? null
                : DailyForecastDomain.fromJson(v as Map<String, dynamic>),
          ),
          outfitImage: $checkedConvert(
            'outfit_image',
            (v) => v == null
                ? const OutfitImage.empty()
                : OutfitImage.fromJson(v as Map<String, dynamic>),
          ),
          outfitRecommendation: $checkedConvert(
            'outfit_recommendation',
            (v) => v as String? ?? '',
          ),
          weather: $checkedConvert(
            'weather',
            (v) =>
                v == null ? null : Weather.fromJson(v as Map<String, dynamic>),
          ),
          message: $checkedConvert('message', (v) => v as String? ?? ''),
        );
        return val;
      },
      fieldKeyMap: const {
        'dailyForecast': 'daily_forecast',
        'outfitImage': 'outfit_image',
        'outfitRecommendation': 'outfit_recommendation',
      },
    );

Map<String, dynamic> _$WeatherSuccessToJson(WeatherSuccess instance) =>
    <String, dynamic>{
      'weather': instance.weather.toJson(),
      'outfit_recommendation': instance.outfitRecommendation,
      'message': instance.message,
      'outfit_image': instance.outfitImage.toJson(),
      'locale': instance.locale,
      'daily_forecast': instance.dailyForecast?.toJson(),
    };

LoadingOutfitState _$LoadingOutfitStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LoadingOutfitState',
      json,
      ($checkedConvert) {
        final val = LoadingOutfitState(
          locale: $checkedConvert('locale', (v) => v as String),
          dailyForecast: $checkedConvert(
            'daily_forecast',
            (v) => v == null
                ? null
                : DailyForecastDomain.fromJson(v as Map<String, dynamic>),
          ),
          outfitRecommendation: $checkedConvert(
            'outfit_recommendation',
            (v) => v as String? ?? '',
          ),
          outfitImage: $checkedConvert(
            'outfit_image',
            (v) => v == null
                ? const OutfitImage.empty()
                : OutfitImage.fromJson(v as Map<String, dynamic>),
          ),
          weather: $checkedConvert(
            'weather',
            (v) =>
                v == null ? null : Weather.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'dailyForecast': 'daily_forecast',
        'outfitRecommendation': 'outfit_recommendation',
        'outfitImage': 'outfit_image',
      },
    );

Map<String, dynamic> _$LoadingOutfitStateToJson(LoadingOutfitState instance) =>
    <String, dynamic>{
      'weather': instance.weather.toJson(),
      'outfit_recommendation': instance.outfitRecommendation,
      'outfit_image': instance.outfitImage.toJson(),
      'locale': instance.locale,
      'daily_forecast': instance.dailyForecast?.toJson(),
    };

WeatherFailure _$WeatherFailureFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherFailure',
      json,
      ($checkedConvert) {
        final val = WeatherFailure(
          locale: $checkedConvert('locale', (v) => v as String),
          outfitImage: $checkedConvert(
            'outfit_image',
            (v) => v == null
                ? const OutfitImage.empty()
                : OutfitImage.fromJson(v as Map<String, dynamic>),
          ),
          outfitRecommendation: $checkedConvert(
            'outfit_recommendation',
            (v) => v as String? ?? '',
          ),
          message: $checkedConvert('message', (v) => v as String? ?? ''),
          dailyForecast: $checkedConvert(
            'daily_forecast',
            (v) => v == null
                ? null
                : DailyForecastDomain.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'outfitImage': 'outfit_image',
        'outfitRecommendation': 'outfit_recommendation',
        'dailyForecast': 'daily_forecast',
      },
    );

Map<String, dynamic> _$WeatherFailureToJson(WeatherFailure instance) =>
    <String, dynamic>{
      'outfit_recommendation': instance.outfitRecommendation,
      'message': instance.message,
      'outfit_image': instance.outfitImage.toJson(),
      'locale': instance.locale,
      'daily_forecast': instance.dailyForecast?.toJson(),
    };

LocalWebCorsFailure _$LocalWebCorsFailureFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LocalWebCorsFailure',
      json,
      ($checkedConvert) {
        final val = LocalWebCorsFailure(
          locale: $checkedConvert('locale', (v) => v as String),
          outfitRecommendation: $checkedConvert(
            'outfit_recommendation',
            (v) => v as String? ?? '',
          ),
          message: $checkedConvert('message', (v) => v as String? ?? ''),
          dailyForecast: $checkedConvert(
            'daily_forecast',
            (v) => v == null
                ? null
                : DailyForecastDomain.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'outfitRecommendation': 'outfit_recommendation',
        'dailyForecast': 'daily_forecast',
      },
    );

Map<String, dynamic> _$LocalWebCorsFailureToJson(
  LocalWebCorsFailure instance,
) => <String, dynamic>{
  'outfit_recommendation': instance.outfitRecommendation,
  'message': instance.message,
  'locale': instance.locale,
  'daily_forecast': instance.dailyForecast?.toJson(),
};
