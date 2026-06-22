// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter

part of 'weather_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherResponse _$WeatherResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'WeatherResponse',
  json,
  ($checkedConvert) {
    final val = WeatherResponse(
      temperature: $checkedConvert('temperature', (v) => (v as num).toDouble()),
      weatherCode: $checkedConvert('weathercode', (v) => (v as num).toDouble()),
      apparentTemperature: $checkedConvert(
        'apparent_temperature',
        (v) => (v as num?)?.toDouble(),
      ),
      relativeHumidity: $checkedConvert(
        'relative_humidity_2m',
        (v) => (v as num?)?.toDouble(),
      ),
      windSpeed: $checkedConvert('windspeed', (v) => (v as num?)?.toDouble()),
      uvIndex: $checkedConvert('uv_index', (v) => (v as num?)?.toDouble()),
      visibility: $checkedConvert('visibility', (v) => (v as num?)?.toDouble()),
      cloudCover: $checkedConvert(
        'cloud_cover',
        (v) => (v as num?)?.toDouble(),
      ),
      pressure: $checkedConvert('pressure_msl', (v) => (v as num?)?.toDouble()),
      dewPoint: $checkedConvert('dew_point_2m', (v) => (v as num?)?.toDouble()),
    );
    return val;
  },
  fieldKeyMap: const {
    'weatherCode': 'weathercode',
    'apparentTemperature': 'apparent_temperature',
    'relativeHumidity': 'relative_humidity_2m',
    'windSpeed': 'windspeed',
    'uvIndex': 'uv_index',
    'cloudCover': 'cloud_cover',
    'pressure': 'pressure_msl',
    'dewPoint': 'dew_point_2m',
  },
);
