import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_units.g.dart';

@JsonSerializable(createToJson: true)
class DailyUnits {
  const DailyUnits({
    this.time = '',
    this.temperature2mMax = '',
    this.temperature2mMin = '',
  });

  factory DailyUnits.fromJson(Map<String, dynamic> json) {
    return _$DailyUnitsFromJson(json);
  }

  final String time;
  @JsonKey(name: 'temperature_2m_max')
  final String temperature2mMax;
  @JsonKey(name: 'temperature_2m_min')
  final String temperature2mMin;

  @override
  String toString() {
    return 'DailyUnits('
        'time: $time, '
        'temperature2mMax: $temperature2mMax, '
        'temperature2mMin: $temperature2mMin,'
        ')';
  }

  Map<String, dynamic> toJson() => _$DailyUnitsToJson(this);

  DailyUnits copyWith({
    String? time,
    String? temperature2mMax,
    String? temperature2mMin,
  }) {
    return DailyUnits(
      time: time ?? this.time,
      temperature2mMax: temperature2mMax ?? this.temperature2mMax,
      temperature2mMin: temperature2mMin ?? this.temperature2mMin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! DailyUnits) return false;
    final bool Function(Object? e1, Object? e2) mapEquals =
        const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      time.hashCode ^ temperature2mMax.hashCode ^ temperature2mMin.hashCode;
}
