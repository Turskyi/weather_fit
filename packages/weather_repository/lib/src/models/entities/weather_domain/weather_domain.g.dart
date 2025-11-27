// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherDomain _$WeatherDomainFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'WeatherDomain',
  json,
  ($checkedConvert) {
    final val = WeatherDomain(
      location: $checkedConvert(
        'location',
        (v) => Location.fromJson(v as Map<String, dynamic>),
      ),
      temperature: $checkedConvert('temperature', (v) => (v as num).toDouble()),
      condition: $checkedConvert(
        'condition',
        (v) => $enumDecode(_$WeatherConditionEnumMap, v),
      ),
      countryCode: $checkedConvert('country_code', (v) => v as String),
      description: $checkedConvert('description', (v) => v as String),
      weatherCode: $checkedConvert('weather_code', (v) => (v as num).toInt()),
      locale: $checkedConvert('locale', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'countryCode': 'country_code',
    'weatherCode': 'weather_code',
  },
);

Map<String, dynamic> _$WeatherDomainToJson(WeatherDomain instance) =>
    <String, dynamic>{
      'location': instance.location,
      'temperature': instance.temperature,
      'condition': _$WeatherConditionEnumMap[instance.condition]!,
      'country_code': instance.countryCode,
      'description': instance.description,
      'weather_code': instance.weatherCode,
      'locale': instance.locale,
    };

const _$WeatherConditionEnumMap = {
  WeatherCondition.clear: 'clear',
  WeatherCondition.rainy: 'rainy',
  WeatherCondition.cloudy: 'cloudy',
  WeatherCondition.snowy: 'snowy',
  WeatherCondition.unknown: 'unknown',
};
