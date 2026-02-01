import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'daily.dart';
import 'daily_units.dart';

part 'climate_change_projections_response.g.dart';

@JsonSerializable(createToJson: true)
class ClimateChangeProjectionsResponse {
  const ClimateChangeProjectionsResponse({
    required this.daily,
    this.latitude,
    this.longitude,
    this.generationtimeMs,
    this.utcOffsetSeconds,
    this.timezone = '',
    this.timezoneAbbreviation = '',
    this.elevation,
    this.dailyUnits,
  });

  factory ClimateChangeProjectionsResponse.fromJson(Map<String, dynamic> json) {
    return _$ClimateChangeProjectionsResponseFromJson(json);
  }

  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'generationtime_ms')
  final double? generationtimeMs;
  @JsonKey(name: 'utc_offset_seconds')
  final int? utcOffsetSeconds;
  final String timezone;
  @JsonKey(name: 'timezone_abbreviation')
  final String timezoneAbbreviation;
  final int? elevation;
  @JsonKey(name: 'daily_units')
  final DailyUnits? dailyUnits;
  final Daily daily;

  @override
  String toString() {
    if (kDebugMode) {
      return 'ClimateChangeProjectionsResponse('
          'latitude: $latitude, '
          'longitude: $longitude, '
          'generationtimeMs: $generationtimeMs, '
          'utcOffsetSeconds: $utcOffsetSeconds, '
          'timezone: $timezone, '
          'timezoneAbbreviation: $timezoneAbbreviation, '
          'elevation: $elevation, '
          'dailyUnits: $dailyUnits, '
          'daily: $daily,'
          ')';
    } else {
      return super.toString();
    }
  }

  Map<String, dynamic> toJson() {
    return _$ClimateChangeProjectionsResponseToJson(this);
  }

  ClimateChangeProjectionsResponse copyWith({
    double? latitude,
    double? longitude,
    double? generationtimeMs,
    int? utcOffsetSeconds,
    String? timezone,
    String? timezoneAbbreviation,
    int? elevation,
    DailyUnits? dailyUnits,
    Daily? daily,
  }) {
    return ClimateChangeProjectionsResponse(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      generationtimeMs: generationtimeMs ?? this.generationtimeMs,
      utcOffsetSeconds: utcOffsetSeconds ?? this.utcOffsetSeconds,
      timezone: timezone ?? this.timezone,
      timezoneAbbreviation: timezoneAbbreviation ?? this.timezoneAbbreviation,
      elevation: elevation ?? this.elevation,
      dailyUnits: dailyUnits ?? this.dailyUnits,
      daily: daily ?? this.daily,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! ClimateChangeProjectionsResponse) return false;
    final bool Function(Object? e1, Object? e2) mapEquals =
        const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      generationtimeMs.hashCode ^
      utcOffsetSeconds.hashCode ^
      timezone.hashCode ^
      timezoneAbbreviation.hashCode ^
      elevation.hashCode ^
      dailyUnits.hashCode ^
      daily.hashCode;
}
