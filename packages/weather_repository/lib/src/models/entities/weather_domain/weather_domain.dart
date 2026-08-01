import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather_domain.g.dart';

@JsonSerializable()
class WeatherDomain extends Equatable {
  const WeatherDomain({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.countryCode,
    required this.description,
    required this.weatherCode,
    required this.locale,
    this.maxTemperature,
    this.minTemperature,
    this.feelsLike,
    this.humidity,
    this.windSpeed,
    this.uvIndex,
    this.visibility,
    this.cloudCover,
    this.pressure,
    this.dewPoint,
  });

  factory WeatherDomain.fromJson(Map<String, Object?> json) {
    return _$WeatherDomainFromJson(json);
  }

  Map<String, Object?> toJson() => _$WeatherDomainToJson(this);

  final Location location;
  final double temperature;
  final WeatherCondition condition;
  final String countryCode;
  final String description;
  final int weatherCode;
  final String locale;
  final double? maxTemperature;
  final double? minTemperature;
  final double? feelsLike;
  final double? humidity;
  final double? windSpeed;
  final double? uvIndex;
  final double? visibility;
  final double? cloudCover;
  final double? pressure;
  final double? dewPoint;

  String get locationName => location.locationName;

  @override
  List<Object?> get props => <Object?>[
    location,
    temperature,
    condition,
    countryCode,
    description,
    weatherCode,
    locale,
    maxTemperature,
    minTemperature,
  ];
}
