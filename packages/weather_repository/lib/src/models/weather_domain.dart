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

  String get locationName => location.name.isEmpty
      ? 'Lat: ${location.latitude.toStringAsFixed(2)}, '
          'Lon: ${location.longitude.toStringAsFixed(2)}'
      : location.name;

  @override
  List<Object> get props => <Object>[
        location,
        temperature,
        condition,
        countryCode,
        description,
        weatherCode,
        locale,
      ];
}
