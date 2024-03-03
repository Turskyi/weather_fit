import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/src/models/weather_condition.dart';

part 'weather_domain.g.dart';

@JsonSerializable()
class WeatherDomain extends Equatable {
  const WeatherDomain({
    required this.location,
    required this.temperature,
    required this.condition,
  });

  factory WeatherDomain.fromJson(Map<String, dynamic> json) =>
      _$WeatherDomainFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherDomainToJson(this);

  final String location;
  final double temperature;
  final WeatherCondition condition;

  @override
  List<Object> get props => <Object>[location, temperature, condition];
}
