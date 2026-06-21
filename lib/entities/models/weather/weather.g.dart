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
        'condition',
        (v) => $enumDecode(_$WeatherConditionEnumMap, v),
      ),
      location: $checkedConvert(
        'location',
        (v) => Location.fromJson(v as Map<String, dynamic>),
      ),
      temperature: $checkedConvert(
        'temperature',
        (v) => Temperature.fromJson(v as Map<String, dynamic>),
      ),
      temperatureUnits: $checkedConvert(
        'temperature_units',
        (v) => $enumDecode(_$TemperatureUnitsEnumMap, v),
      ),
      countryCode: $checkedConvert('country_code', (v) => v as String),
      description: $checkedConvert('description', (v) => v as String),
      code: $checkedConvert('code', (v) => (v as num).toInt()),
      locale: $checkedConvert('locale', (v) => v as String),
      lastUpdatedDateTime: $checkedConvert(
        'last_updated_date_time',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      feelsLike: $checkedConvert(
        'feels_like',
        (v) =>
            v == null ? null : Temperature.fromJson(v as Map<String, dynamic>),
      ),
      humidity: $checkedConvert('humidity', (v) => (v as num?)?.toDouble()),
      windSpeed: $checkedConvert('wind_speed', (v) => (v as num?)?.toDouble()),
      uvIndex: $checkedConvert('uv_index', (v) => (v as num?)?.toDouble()),
      visibility: $checkedConvert('visibility', (v) => (v as num?)?.toDouble()),
      cloudCover: $checkedConvert(
        'cloud_cover',
        (v) => (v as num?)?.toDouble(),
      ),
      pressure: $checkedConvert('pressure', (v) => (v as num?)?.toDouble()),
      dewPoint: $checkedConvert('dew_point', (v) => (v as num?)?.toDouble()),
    );
    return val;
  },
  fieldKeyMap: const {
    'temperatureUnits': 'temperature_units',
    'countryCode': 'country_code',
    'lastUpdatedDateTime': 'last_updated_date_time',
    'feelsLike': 'feels_like',
    'windSpeed': 'wind_speed',
    'uvIndex': 'uv_index',
    'cloudCover': 'cloud_cover',
    'dewPoint': 'dew_point',
  },
);

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
  'condition': _$WeatherConditionEnumMap[instance.condition]!,
  'last_updated_date_time': instance.lastUpdatedDateTime?.toIso8601String(),
  'location': instance.location.toJson(),
  'temperature': instance.temperature.toJson(),
  'temperature_units': _$TemperatureUnitsEnumMap[instance.temperatureUnits]!,
  'country_code': instance.countryCode,
  'description': instance.description,
  'code': instance.code,
  'locale': instance.locale,
  'feels_like': instance.feelsLike?.toJson(),
  'humidity': instance.humidity,
  'wind_speed': instance.windSpeed,
  'uv_index': instance.uvIndex,
  'visibility': instance.visibility,
  'cloud_cover': instance.cloudCover,
  'pressure': instance.pressure,
  'dew_point': instance.dewPoint,
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
