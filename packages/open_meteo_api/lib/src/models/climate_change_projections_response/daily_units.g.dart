// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter

part of 'daily_units.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyUnits _$DailyUnitsFromJson(Map<String, dynamic> json) => $checkedCreate(
  'DailyUnits',
  json,
  ($checkedConvert) {
    final val = DailyUnits(
      time: $checkedConvert('time', (v) => v as String?),
      temperature2mMax: $checkedConvert(
        'temperature_2m_max',
        (v) => v as String?,
      ),
      temperature2mMin: $checkedConvert(
        'temperature_2m_min',
        (v) => v as String?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'temperature2mMax': 'temperature_2m_max',
    'temperature2mMin': 'temperature_2m_min',
  },
);

Map<String, dynamic> _$DailyUnitsToJson(DailyUnits instance) =>
    <String, dynamic>{
      'time': instance.time,
      'temperature_2m_max': instance.temperature2mMax,
      'temperature_2m_min': instance.temperature2mMin,
    };
