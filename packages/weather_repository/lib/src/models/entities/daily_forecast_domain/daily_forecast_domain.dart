import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart';

part 'daily_forecast_domain.g.dart';

@JsonSerializable()
class DailyForecastDomain extends Equatable {
  const DailyForecastDomain({
    required this.forecast,
    this.daily = const <ForecastDayDomain>[],
  });

  factory DailyForecastDomain.fromJson(Map<String, Object?> json) {
    return _$DailyForecastDomainFromJson(json);
  }

  final List<ForecastItemDomain> forecast;
  final List<ForecastDayDomain> daily;

  Map<String, Object?> toJson() => _$DailyForecastDomainToJson(this);

  @override
  List<Object> get props => <Object>[forecast, daily];
}
