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
    this.apparentTemperature,
    this.relativeHumidity2m,
    this.windSpeed10m,
    this.uvIndex,
    this.visibility,
    this.cloudCover,
    this.pressureMSL,
    this.dewPoint2m,
  });

  factory Hourly.fromJson(Map<String, Object?> json) => _$HourlyFromJson(json);

  final List<String> time;
  @JsonKey(name: 'temperature_2m')
  final List<double> temperature2m;
  final List<int> weathercode;
  @JsonKey(name: 'apparent_temperature')
  final List<double>? apparentTemperature;
  @JsonKey(name: 'relative_humidity_2m')
  final List<double>? relativeHumidity2m;
  @JsonKey(name: 'wind_speed_10m')
  final List<double>? windSpeed10m;
  @JsonKey(name: 'uv_index')
  final List<double>? uvIndex;
  final List<double>? visibility;
  @JsonKey(name: 'cloud_cover')
  final List<double>? cloudCover;
  @JsonKey(name: 'pressure_msl')
  final List<double>? pressureMSL;
  @JsonKey(name: 'dew_point_2m')
  final List<double>? dewPoint2m;
}
