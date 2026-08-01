// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_day_domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastDayDomain _$ForecastDayDomainFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ForecastDayDomain',
      json,
      ($checkedConvert) {
        final val = ForecastDayDomain(
          time: $checkedConvert('time', (v) => v as String),
          weatherCode: $checkedConvert(
            'weather_code',
            (v) => (v as num).toInt(),
          ),
          maxTemp: $checkedConvert('max_temp', (v) => (v as num).toDouble()),
          minTemp: $checkedConvert('min_temp', (v) => (v as num).toDouble()),
        );
        return val;
      },
      fieldKeyMap: const {
        'weatherCode': 'weather_code',
        'maxTemp': 'max_temp',
        'minTemp': 'min_temp',
      },
    );

Map<String, dynamic> _$ForecastDayDomainToJson(ForecastDayDomain instance) =>
    <String, dynamic>{
      'time': instance.time,
      'weather_code': instance.weatherCode,
      'max_temp': instance.maxTemp,
      'min_temp': instance.minTemp,
    };
