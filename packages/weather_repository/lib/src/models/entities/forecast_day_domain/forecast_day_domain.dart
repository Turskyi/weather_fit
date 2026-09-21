import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart';

part 'forecast_day_domain.g.dart';

@JsonSerializable()
class ForecastDayDomain extends Equatable {
  const ForecastDayDomain({
    required this.time,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
  });

  factory ForecastDayDomain.fromJson(Map<String, Object?> json) {
    return _$ForecastDayDomainFromJson(json);
  }

  final String time;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;

  Map<String, Object?> toJson() => _$ForecastDayDomainToJson(this);

  WeatherCondition toCondition() {
    switch (weatherCode) {
      case 0:
        return WeatherCondition.clear;
      case 1:
      case 2:
      case 3:
      case 45:
      case 48:
        return WeatherCondition.cloudy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
      case 95:
      case 96:
      case 99:
        return WeatherCondition.rainy;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return WeatherCondition.snowy;
      default:
        return WeatherCondition.unknown;
    }
  }

  @override
  List<Object?> get props => <Object?>[time, weatherCode, maxTemp, minTemp];
}
