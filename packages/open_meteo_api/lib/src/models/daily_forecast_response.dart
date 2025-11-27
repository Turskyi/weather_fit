import 'package:json_annotation/json_annotation.dart';

part 'daily_forecast_response.g.dart';

@JsonSerializable()
class DailyForecastResponse {
  const DailyForecastResponse({required this.hourly});

  factory DailyForecastResponse.fromJson(Map<String, Object?> json) =>
      _$DailyForecastResponseFromJson(json);

  final Hourly hourly;
}

@JsonSerializable()
class Hourly {
  const Hourly({
    required this.time,
    required this.temperature2m,
    required this.weathercode,
  });

  factory Hourly.fromJson(Map<String, Object?> json) => _$HourlyFromJson(json);

  final List<String> time;
  @JsonKey(name: 'temperature_2m')
  final List<double> temperature2m;
  final List<int> weathercode;
}
