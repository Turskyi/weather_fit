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

Hourly _$HourlyFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Hourly', json, ($checkedConvert) {
      final val = Hourly(
        time: $checkedConvert(
          'time',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        temperature2m: $checkedConvert(
          'temperature_2m',
          (v) =>
              (v as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
        ),
        weathercode: $checkedConvert(
          'weathercode',
          (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'temperature2m': 'temperature_2m'});
