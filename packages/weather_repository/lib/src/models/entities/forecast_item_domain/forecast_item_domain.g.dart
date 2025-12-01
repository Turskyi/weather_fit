// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_item_domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastItemDomain _$ForecastItemDomainFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ForecastItemDomain', json, ($checkedConvert) {
      final val = ForecastItemDomain(
        time: $checkedConvert('time', (v) => v as String),
        temperature: $checkedConvert(
          'temperature',
          (v) => (v as num).toDouble(),
        ),
        weatherCode: $checkedConvert('weather_code', (v) => (v as num).toInt()),
      );
      return val;
    }, fieldKeyMap: const {'weatherCode': 'weather_code'});

Map<String, dynamic> _$ForecastItemDomainToJson(ForecastItemDomain instance) =>
    <String, dynamic>{
      'time': instance.time,
      'temperature': instance.temperature,
      'weather_code': instance.weatherCode,
    };
