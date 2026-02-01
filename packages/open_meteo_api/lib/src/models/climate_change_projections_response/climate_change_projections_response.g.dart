// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter

part of 'climate_change_projections_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClimateChangeProjectionsResponse _$ClimateChangeProjectionsResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ClimateChangeProjectionsResponse',
  json,
  ($checkedConvert) {
    final val = ClimateChangeProjectionsResponse(
      daily: $checkedConvert(
        'daily',
        (v) => Daily.fromJson(v as Map<String, dynamic>),
      ),
      latitude: $checkedConvert('latitude', (v) => (v as num?)?.toDouble()),
      longitude: $checkedConvert('longitude', (v) => (v as num?)?.toDouble()),
      generationtimeMs: $checkedConvert(
        'generationtime_ms',
        (v) => (v as num?)?.toDouble(),
      ),
      utcOffsetSeconds: $checkedConvert(
        'utc_offset_seconds',
        (v) => (v as num?)?.toInt(),
      ),
      timezone: $checkedConvert('timezone', (v) => v as String? ?? ''),
      timezoneAbbreviation: $checkedConvert(
        'timezone_abbreviation',
        (v) => v as String? ?? '',
      ),
      elevation: $checkedConvert('elevation', (v) => (v as num?)?.toInt()),
      dailyUnits: $checkedConvert(
        'daily_units',
        (v) =>
            v == null ? null : DailyUnits.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'generationtimeMs': 'generationtime_ms',
    'utcOffsetSeconds': 'utc_offset_seconds',
    'timezoneAbbreviation': 'timezone_abbreviation',
    'dailyUnits': 'daily_units',
  },
);

Map<String, dynamic> _$ClimateChangeProjectionsResponseToJson(
  ClimateChangeProjectionsResponse instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'generationtime_ms': instance.generationtimeMs,
  'utc_offset_seconds': instance.utcOffsetSeconds,
  'timezone': instance.timezone,
  'timezone_abbreviation': instance.timezoneAbbreviation,
  'elevation': instance.elevation,
  'daily_units': instance.dailyUnits,
  'daily': instance.daily,
};
