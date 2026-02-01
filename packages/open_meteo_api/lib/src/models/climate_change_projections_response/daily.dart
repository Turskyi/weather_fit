import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily.g.dart';

@JsonSerializable(createToJson: true)
class Daily {
  const Daily({
    this.time = const <String>[],
    this.temperature2mMax = const <double>[],
    this.temperature2mMin = const <double>[],
  });

  factory Daily.fromJson(Map<String, dynamic> json) => _$DailyFromJson(json);

  final List<String> time;
  @JsonKey(name: 'temperature_2m_max')
  final List<double> temperature2mMax;
  @JsonKey(name: 'temperature_2m_min')
  final List<double> temperature2mMin;

  @override
  String toString() {
    return 'Daily('
        'time: $time, '
        'temperature2mMax: $temperature2mMax, '
        'temperature2mMin: $temperature2mMin,'
        ')';
  }

  Map<String, dynamic> toJson() => _$DailyToJson(this);

  Daily copyWith({
    List<String>? time,
    List<double>? temperature2mMax,
    List<double>? temperature2mMin,
  }) {
    return Daily(
      time: time ?? this.time,
      temperature2mMax: temperature2mMax ?? this.temperature2mMax,
      temperature2mMin: temperature2mMin ?? this.temperature2mMin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Daily) return false;
    final bool Function(Object? e1, Object? e2) mapEquals =
        const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      time.hashCode ^ temperature2mMax.hashCode ^ temperature2mMin.hashCode;
}
