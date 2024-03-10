// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherState _$WeatherStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherState',
      json,
      ($checkedConvert) {
        final val = WeatherState(
          outfitImageUrl:
              $checkedConvert('outfit_image_url', (v) => v as String? ?? ''),
          status: $checkedConvert(
              'status',
              (v) => $enumDecodeNullable(_$WeatherStatusEnumMap, v) ?? kIsWeb
                  ? WeatherStatus.initial
                  : WeatherStatus.loading),
          weather: $checkedConvert(
              'weather',
              (v) => v == null
                  ? null
                  : Weather.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
      fieldKeyMap: const {'outfitImageUrl': 'outfit_image_url'},
    );

Map<String, dynamic> _$WeatherStateToJson(WeatherState instance) =>
    <String, dynamic>{
      'status': _$WeatherStatusEnumMap[instance.status]!,
      'weather': instance.weather.toJson(),
      'outfit_image_url': instance.outfitImageUrl,
    };

const _$WeatherStatusEnumMap = {
  WeatherStatus.initial: 'initial',
  WeatherStatus.loading: 'loading',
  WeatherStatus.success: 'success',
  WeatherStatus.failure: 'failure',
};
