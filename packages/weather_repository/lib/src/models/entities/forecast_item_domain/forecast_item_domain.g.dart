// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_item_domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastItemDomain _$ForecastItemDomainFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ForecastItemDomain',
  json,
  ($checkedConvert) {
    final val = ForecastItemDomain(
      time: $checkedConvert('time', (v) => v as String),
      temperature: $checkedConvert('temperature', (v) => (v as num).toDouble()),
      weatherCode: $checkedConvert('weather_code', (v) => (v as num).toInt()),
      feelsLike: $checkedConvert('feels_like', (v) => (v as num?)?.toDouble()),
      humidity: $checkedConvert('humidity', (v) => (v as num?)?.toDouble()),
      windSpeed: $checkedConvert('wind_speed', (v) => (v as num?)?.toDouble()),
      uvIndex: $checkedConvert('uv_index', (v) => (v as num?)?.toDouble()),
      visibility: $checkedConvert('visibility', (v) => (v as num?)?.toDouble()),
      cloudCover: $checkedConvert(
        'cloud_cover',
        (v) => (v as num?)?.toDouble(),
      ),
      pressure: $checkedConvert('pressure', (v) => (v as num?)?.toDouble()),
      dewPoint: $checkedConvert('dew_point', (v) => (v as num?)?.toDouble()),
    );
    return val;
  },
  fieldKeyMap: const {
    'weatherCode': 'weather_code',
    'feelsLike': 'feels_like',
    'windSpeed': 'wind_speed',
    'uvIndex': 'uv_index',
    'cloudCover': 'cloud_cover',
    'dewPoint': 'dew_point',
  },
);

Map<String, dynamic> _$ForecastItemDomainToJson(ForecastItemDomain instance) =>
    <String, dynamic>{
      'time': instance.time,
      'temperature': instance.temperature,
      'weather_code': instance.weatherCode,
      'feels_like': instance.feelsLike,
      'humidity': instance.humidity,
      'wind_speed': instance.windSpeed,
      'uv_index': instance.uvIndex,
      'visibility': instance.visibility,
      'cloud_cover': instance.cloudCover,
      'pressure': instance.pressure,
      'dew_point': instance.dewPoint,
    };
