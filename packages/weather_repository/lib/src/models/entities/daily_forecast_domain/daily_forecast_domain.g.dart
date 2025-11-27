// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_forecast_domain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyForecastDomain _$DailyForecastDomainFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DailyForecastDomain', json, ($checkedConvert) {
      final val = DailyForecastDomain(
        forecast: $checkedConvert(
          'forecast',
          (v) => (v as List<dynamic>)
              .map(
                (e) => ForecastItemDomain.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DailyForecastDomainToJson(
  DailyForecastDomain instance,
) => <String, dynamic>{'forecast': instance.forecast};
