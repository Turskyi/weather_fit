import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'forecast_item_domain.g.dart';

@JsonSerializable()
class ForecastItemDomain extends Equatable {
  const ForecastItemDomain({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });

  factory ForecastItemDomain.fromJson(Map<String, dynamic> json) {
    return _$ForecastItemDomainFromJson(json);
  }

  final String time;
  final double temperature;
  final int weatherCode;

  Map<String, dynamic> toJson() => _$ForecastItemDomainToJson(this);

  @override
  List<Object> get props => <Object>[time, temperature, weatherCode];
}
