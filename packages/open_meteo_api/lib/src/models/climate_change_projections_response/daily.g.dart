// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter

part of 'daily.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Daily _$DailyFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Daily',
  json,
  ($checkedConvert) {
    final val = Daily(
      time: $checkedConvert(
        'time',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ??
            const <String>[],
      ),
      temperature2mMax: $checkedConvert(
        'temperature_2m_max',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ??
            const <double>[],
      ),
      temperature2mMin: $checkedConvert(
        'temperature_2m_min',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ??
            const <double>[],
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'temperature2mMax': 'temperature_2m_max',
    'temperature2mMin': 'temperature_2m_min',
  },
);

Map<String, dynamic> _$DailyToJson(Daily instance) => <String, dynamic>{
  'time': instance.time,
  'temperature_2m_max': instance.temperature2mMax,
  'temperature_2m_min': instance.temperature2mMin,
};
