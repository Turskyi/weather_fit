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
          outfitRecommendation: $checkedConvert(
              'outfit_recommendation', (v) => v as String? ?? ''),
          weather: $checkedConvert(
              'weather',
              (v) => v == null
                  ? null
                  : Weather.fromJson(v as Map<String, dynamic>)),
          outfitAssetPath:
              $checkedConvert('outfit_asset_path', (v) => v as String? ?? ''),
        );
        return val;
      },
      fieldKeyMap: const {
        'outfitRecommendation': 'outfit_recommendation',
        'outfitAssetPath': 'outfit_asset_path'
      },
    );

Map<String, dynamic> _$WeatherInitialToJson(WeatherInitial instance) =>
    <String, dynamic>{
      'weather': instance.weather.toJson(),
      'outfit_recommendation': instance.outfitRecommendation,
      'outfit_asset_path': instance.outfitAssetPath,
    };

WeatherLoadingState _$WeatherLoadingStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherLoadingState',
      json,
      ($checkedConvert) {
        final val = WeatherLoadingState(
          outfitRecommendation: $checkedConvert(
              'outfit_recommendation', (v) => v as String? ?? ''),
          weather: $checkedConvert(
              'weather',
              (v) => v == null
                  ? null
                  : Weather.fromJson(v as Map<String, dynamic>)),
          outfitAssetPath:
              $checkedConvert('outfit_asset_path', (v) => v as String? ?? ''),
        );
        return val;
      },
      fieldKeyMap: const {
        'outfitRecommendation': 'outfit_recommendation',
        'outfitAssetPath': 'outfit_asset_path'
      },
    );

Map<String, dynamic> _$WeatherLoadingStateToJson(
        WeatherLoadingState instance) =>
    <String, dynamic>{
      'weather': instance.weather.toJson(),
      'outfit_recommendation': instance.outfitRecommendation,
      'outfit_asset_path': instance.outfitAssetPath,
    };

WeatherSuccess _$WeatherSuccessFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherSuccess',
      json,
      ($checkedConvert) {
        final val = WeatherSuccess(
          outfitAssetPath:
              $checkedConvert('outfit_asset_path', (v) => v as String? ?? ''),
          outfitRecommendation: $checkedConvert(
              'outfit_recommendation', (v) => v as String? ?? ''),
          weather: $checkedConvert(
              'weather',
              (v) => v == null
                  ? null
                  : Weather.fromJson(v as Map<String, dynamic>)),
          message: $checkedConvert('message', (v) => v as String? ?? ''),
        );
        return val;
      },
      fieldKeyMap: const {
        'outfitAssetPath': 'outfit_asset_path',
        'outfitRecommendation': 'outfit_recommendation'
      },
    );

Map<String, dynamic> _$WeatherSuccessToJson(WeatherSuccess instance) =>
    <String, dynamic>{
      'weather': instance.weather.toJson(),
      'outfit_recommendation': instance.outfitRecommendation,
      'message': instance.message,
      'outfit_asset_path': instance.outfitAssetPath,
    };

LoadingOutfitState _$LoadingOutfitStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LoadingOutfitState',
      json,
      ($checkedConvert) {
        final val = LoadingOutfitState(
          outfitRecommendation: $checkedConvert(
              'outfit_recommendation', (v) => v as String? ?? ''),
          outfitAssetPath:
              $checkedConvert('outfit_asset_path', (v) => v as String? ?? ''),
          weather: $checkedConvert(
              'weather',
              (v) => v == null
                  ? null
                  : Weather.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
      fieldKeyMap: const {
        'outfitRecommendation': 'outfit_recommendation',
        'outfitAssetPath': 'outfit_asset_path'
      },
    );

Map<String, dynamic> _$LoadingOutfitStateToJson(LoadingOutfitState instance) =>
    <String, dynamic>{
      'weather': instance.weather.toJson(),
      'outfit_recommendation': instance.outfitRecommendation,
      'outfit_asset_path': instance.outfitAssetPath,
    };

WeatherFailure _$WeatherFailureFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherFailure',
      json,
      ($checkedConvert) {
        final val = WeatherFailure(
          outfitAssetPath:
              $checkedConvert('outfit_asset_path', (v) => v as String? ?? ''),
          outfitRecommendation: $checkedConvert(
              'outfit_recommendation', (v) => v as String? ?? ''),
          message: $checkedConvert('message', (v) => v as String? ?? ''),
        );
        return val;
      },
      fieldKeyMap: const {
        'outfitAssetPath': 'outfit_asset_path',
        'outfitRecommendation': 'outfit_recommendation'
      },
    );

Map<String, dynamic> _$WeatherFailureToJson(WeatherFailure instance) =>
    <String, dynamic>{
      'outfit_recommendation': instance.outfitRecommendation,
      'message': instance.message,
      'outfit_asset_path': instance.outfitAssetPath,
    };

LocalWebCorsFailure _$LocalWebCorsFailureFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LocalWebCorsFailure',
      json,
      ($checkedConvert) {
        final val = LocalWebCorsFailure(
          outfitRecommendation: $checkedConvert(
              'outfit_recommendation', (v) => v as String? ?? ''),
          message: $checkedConvert('message', (v) => v as String? ?? ''),
        );
        return val;
      },
      fieldKeyMap: const {'outfitRecommendation': 'outfit_recommendation'},
    );

Map<String, dynamic> _$LocalWebCorsFailureToJson(
        LocalWebCorsFailure instance) =>
    <String, dynamic>{
      'outfit_recommendation': instance.outfitRecommendation,
      'message': instance.message,
    };
