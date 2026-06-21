// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter

part of 'daily_forecast_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyForecastResponse _$DailyForecastResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyForecastResponse', json, ($checkedConvert) {
  final val = DailyForecastResponse(
    hourly: $checkedConvert(
      'hourly',
      (v) => Hourly.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Hourly _$HourlyFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Hourly',
  json,
  ($checkedConvert) {
    final val = Hourly(
      time: $checkedConvert(
        'time',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      temperature2m: $checkedConvert(
        'temperature_2m',
        (v) => (v as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      ),
      weathercode: $checkedConvert(
        'weathercode',
        (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
      ),
      apparentTemperature: $checkedConvert(
        'apparent_temperature',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      ),
      relativeHumidity2m: $checkedConvert(
        'relative_humidity_2m',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      ),
      windSpeed10m: $checkedConvert(
        'wind_speed_10m',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      ),
      uvIndex: $checkedConvert(
        'uv_index',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      ),
      visibility: $checkedConvert(
        'visibility',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      ),
      cloudCover: $checkedConvert(
        'cloud_cover',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      ),
      pressureMSL: $checkedConvert(
        'pressure_msl',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      ),
      dewPoint2m: $checkedConvert(
        'dew_point_2m',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'temperature2m': 'temperature_2m',
    'apparentTemperature': 'apparent_temperature',
    'relativeHumidity2m': 'relative_humidity_2m',
    'windSpeed10m': 'wind_speed_10m',
    'uvIndex': 'uv_index',
    'cloudCover': 'cloud_cover',
    'pressureMSL': 'pressure_msl',
    'dewPoint2m': 'dew_point_2m',
  },
);
