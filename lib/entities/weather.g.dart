// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Weather _$WeatherFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Weather',
      json,
      ($checkedConvert) {
        final val = Weather(
          condition: $checkedConvert(
              'condition', (v) => $enumDecode(_$WeatherConditionEnumMap, v)),
          lastUpdated: $checkedConvert('last_updated',
              (v) => v == null ? null : DateTime.parse(v as String)),
          city: $checkedConvert('city', (v) => v as String),
          temperature: $checkedConvert('temperature',
              (v) => Temperature.fromJson(v as Map<String, dynamic>)),
          temperatureUnits: $checkedConvert('temperature_units',
              (v) => $enumDecode(_$TemperatureUnitsEnumMap, v)),
          countryCode: $checkedConvert('country_code', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'lastUpdated': 'last_updated',
        'temperatureUnits': 'temperature_units',
        'countryCode': 'country_code'
      },
    );

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'condition': _$WeatherConditionEnumMap[instance.condition]!,
      'last_updated': instance.lastUpdated?.toIso8601String(),
      'city': instance.city,
      'temperature': instance.temperature.toJson(),
      'temperature_units':
          _$TemperatureUnitsEnumMap[instance.temperatureUnits]!,
      'country_code': instance.countryCode,
    };

const _$WeatherConditionEnumMap = {
  WeatherCondition.clear: 'clear',
  WeatherCondition.rainy: 'rainy',
  WeatherCondition.cloudy: 'cloudy',
  WeatherCondition.snowy: 'snowy',
  WeatherCondition.unknown: 'unknown',
};

const _$TemperatureUnitsEnumMap = {
  TemperatureUnits.fahrenheit: 'fahrenheit',
  TemperatureUnits.celsius: 'celsius',
};
