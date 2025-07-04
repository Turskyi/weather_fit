// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter

part of 'location_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationResponse _$LocationResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LocationResponse',
      json,
      ($checkedConvert) {
        final val = LocationResponse(
          id: $checkedConvert('id', (v) => (v as num).toInt()),
          name: $checkedConvert('name', (v) => v as String),
          latitude: $checkedConvert('latitude', (v) => (v as num).toDouble()),
          longitude: $checkedConvert('longitude', (v) => (v as num).toDouble()),
          countryCode: $checkedConvert('country_code', (v) => v as String),
          country: $checkedConvert('country', (v) => v as String),
          admin1: $checkedConvert('admin1', (v) => v as String? ?? ''),
        );
        return val;
      },
      fieldKeyMap: const {'countryCode': 'country_code'},
    );
