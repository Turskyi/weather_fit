// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherDomain _$WeatherDomainFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeatherDomain',
      json,
      ($checkedConvert) {
        final val = WeatherDomain(
          location: $checkedConvert('location', (v) => v as String),
          temperature:
              $checkedConvert('temperature', (v) => (v as num).toDouble()),
          condition: $checkedConvert(
              'condition', (v) => $enumDecode(_$WeatherConditionEnumMap, v)),
          countryCode: $checkedConvert('country_code', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {'countryCode': 'country_code'},
    );

Map<String, dynamic> _$WeatherDomainToJson(WeatherDomain instance) =>
    <String, dynamic>{
      'location': instance.location,
      'temperature': instance.temperature,
      'condition': _$WeatherConditionEnumMap[instance.condition]!,
      'country_code': instance.countryCode,
    };

const _$WeatherConditionEnumMap = {
  WeatherCondition.clear: 'clear',
  WeatherCondition.rainy: 'rainy',
  WeatherCondition.cloudy: 'cloudy',
  WeatherCondition.snowy: 'snowy',
  WeatherCondition.unknown: 'unknown',
};
