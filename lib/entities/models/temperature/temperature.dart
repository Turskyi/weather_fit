import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'temperature.g.dart';

@JsonSerializable()
class Temperature extends Equatable {
  const Temperature({required this.value});

  factory Temperature.fromJson(Map<String, Object?> json) {
    return _$TemperatureFromJson(json);
  }

  final double value;

  Map<String, Object?> toJson() => _$TemperatureToJson(this);

  @override
  List<Object> get props => <Object>[value];
}
