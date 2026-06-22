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
      maxTemperature: $checkedConvert(
        'max_temperature',
        (v) => (v as num?)?.toDouble(),
      ),
      minTemperature: $checkedConvert(
        'min_temperature',
        (v) => (v as num?)?.toDouble(),
      ),
      feelsLike: $checkedConvert('feels_like', (v) => (v as num?)?.toDouble()),
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
    'countryCode': 'country_code',
    'weatherCode': 'weather_code',
    'maxTemperature': 'max_temperature',
    'minTemperature': 'min_temperature',
    'feelsLike': 'feels_like',
    'windSpeed': 'wind_speed',
    'uvIndex': 'uv_index',
    'cloudCover': 'cloud_cover',
    'dewPoint': 'dew_point',
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
      'max_temperature': instance.maxTemperature,
      'min_temperature': instance.minTemperature,
      'feels_like': instance.feelsLike,
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
