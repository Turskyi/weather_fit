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
          location: $checkedConvert(
              'location', (v) => Location.fromJson(v as Map<String, dynamic>)),
          temperature: $checkedConvert('temperature',
              (v) => Temperature.fromJson(v as Map<String, dynamic>)),
          temperatureUnits: $checkedConvert('temperature_units',
              (v) => $enumDecode(_$TemperatureUnitsEnumMap, v)),
          countryCode: $checkedConvert('country_code', (v) => v as String),
          lastUpdatedDateTime: $checkedConvert('last_updated_date_time',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {
        'temperatureUnits': 'temperature_units',
        'countryCode': 'country_code',
        'lastUpdatedDateTime': 'last_updated_date_time'
      },
    );

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'condition': _$WeatherConditionEnumMap[instance.condition]!,
      'last_updated_date_time': instance.lastUpdatedDateTime?.toIso8601String(),
      'location': instance.location.toJson(),
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
