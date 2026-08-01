import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'forecast_day_domain.g.dart';

@JsonSerializable()
class ForecastDayDomain extends Equatable {
  const ForecastDayDomain({
    required this.time,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
  });

  factory ForecastDayDomain.fromJson(Map<String, Object?> json) =>
      _$ForecastDayDomainFromJson(json);

  final String time;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;

  Map<String, Object?> toJson() => _$ForecastDayDomainToJson(this);

  @override
  List<Object?> get props => <Object?>[time, weatherCode, maxTemp, minTemp];
}
