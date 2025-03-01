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
          weather: $checkedConvert(
              'weather',
              (v) => v == null
                  ? null
                  : Weather.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$WeatherInitialToJson(WeatherInitial instance) =>
    <String, dynamic>{
      'weather': instance.weather.toJson(),
    };

WeatherLoadingState _$WeatherLoadingStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherLoadingState',
      json,
      ($checkedConvert) {
        final val = WeatherLoadingState(
          weather: $checkedConvert(
              'weather',
              (v) => v == null
                  ? null
                  : Weather.fromJson(v as Map<String, dynamic>)),
          outfitImageUrl:
              $checkedConvert('outfit_image_url', (v) => v as String? ?? ''),
          outfitImagePath:
              $checkedConvert('outfit_image_path', (v) => v as String? ?? ''),
        );
        return val;
      },
      fieldKeyMap: const {
        'outfitImageUrl': 'outfit_image_url',
        'outfitImagePath': 'outfit_image_path'
      },
    );

Map<String, dynamic> _$WeatherLoadingStateToJson(
        WeatherLoadingState instance) =>
    <String, dynamic>{
      'weather': instance.weather.toJson(),
      'outfit_image_url': instance.outfitImageUrl,
      'outfit_image_path': instance.outfitImagePath,
    };

WeatherSuccess _$WeatherSuccessFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherSuccess',
      json,
      ($checkedConvert) {
        final val = WeatherSuccess(
          outfitImageUrl:
              $checkedConvert('outfit_image_url', (v) => v as String),
          weather: $checkedConvert(
              'weather',
              (v) => v == null
                  ? null
                  : Weather.fromJson(v as Map<String, dynamic>)),
          outfitImagePath:
              $checkedConvert('outfit_image_path', (v) => v as String? ?? ''),
          snackbarMessage:
              $checkedConvert('snackbar_message', (v) => v as String? ?? ''),
        );
        return val;
      },
      fieldKeyMap: const {
        'outfitImageUrl': 'outfit_image_url',
        'outfitImagePath': 'outfit_image_path',
        'snackbarMessage': 'snackbar_message'
      },
    );

Map<String, dynamic> _$WeatherSuccessToJson(WeatherSuccess instance) =>
    <String, dynamic>{
      'weather': instance.weather.toJson(),
      'outfit_image_url': instance.outfitImageUrl,
      'outfit_image_path': instance.outfitImagePath,
      'snackbar_message': instance.snackbarMessage,
    };

LoadingOutfitState _$LoadingOutfitStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LoadingOutfitState',
      json,
      ($checkedConvert) {
        final val = LoadingOutfitState(
          weather: $checkedConvert(
              'weather',
              (v) => v == null
                  ? null
                  : Weather.fromJson(v as Map<String, dynamic>)),
          outfitImageUrl:
              $checkedConvert('outfit_image_url', (v) => v as String? ?? ''),
        );
        return val;
      },
      fieldKeyMap: const {'outfitImageUrl': 'outfit_image_url'},
    );

Map<String, dynamic> _$LoadingOutfitStateToJson(LoadingOutfitState instance) =>
    <String, dynamic>{
      'weather': instance.weather.toJson(),
      'outfit_image_url': instance.outfitImageUrl,
    };

WeatherFailure _$WeatherFailureFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherFailure',
      json,
      ($checkedConvert) {
        final val = WeatherFailure(
          message: $checkedConvert('message', (v) => v as String? ?? ''),
        );
        return val;
      },
    );

Map<String, dynamic> _$WeatherFailureToJson(WeatherFailure instance) =>
    <String, dynamic>{
      'message': instance.message,
    };
