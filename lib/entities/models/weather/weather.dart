import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_repository/weather_repository.dart';

part 'weather.g.dart';

@JsonSerializable()
class Weather extends Equatable {
  const Weather({
    required this.condition,
    required this.location,
    required this.temperature,
    required this.temperatureUnits,
    required this.countryCode,
    required this.description,
    required this.code,
    required this.locale,
    this.lastUpdatedDateTime,
  });

  factory Weather.fromJson(Map<String, Object?> json) {
    return _$WeatherFromJson(json);
  }

  factory Weather.fromRepository(WeatherDomain weatherDomain) {
    final DateTime now = DateTime.now();
    final DateTime parsedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

    return Weather(
      condition: weatherDomain.condition,
      lastUpdatedDateTime: parsedDateTime,
      location: weatherDomain.location,
      temperature: Temperature(value: weatherDomain.temperature),
      temperatureUnits: TemperatureUnits.celsius,
      countryCode: weatherDomain.countryCode,
      description: weatherDomain.description,
      code: weatherDomain.weatherCode,
      locale: weatherDomain.locale,
    );
  }

  final WeatherCondition condition;
  final DateTime? lastUpdatedDateTime;
  final Location location;
  final Temperature temperature;
  final TemperatureUnits temperatureUnits;
  final String countryCode;
  final String description;
  final int code;
  final String locale;

  static const Weather empty = Weather(
    condition: WeatherCondition.unknown,
    temperature: Temperature(value: 0),
    location: Location.empty(),
    temperatureUnits: TemperatureUnits.celsius,
    countryCode: '',
    description: '',
    code: 0,
    locale: '',
  );

  @override
  List<Object?> get props => <Object?>[
        condition,
        lastUpdatedDateTime,
        location,
        temperature,
        temperatureUnits,
        countryCode,
        description,
        code,
        locale,
      ];

  @override
  String toString() {
    return 'Weather{'
        'condition: $condition, '
        'location: $location, '
        'temperature: $temperature, '
        'temperatureUnits: $temperatureUnits, '
        'countryCode: $countryCode,'
        'lastUpdatedDateTime: $lastUpdatedDateTime,'
        'description: $description,'
        'code: $code,'
        'locale: $locale'
        '}';
  }

  Map<String, Object?> toJson() => _$WeatherToJson(this);

  Weather copyWith({
    WeatherCondition? condition,
    DateTime? lastUpdatedDateTime,
    Location? location,
    Temperature? temperature,
    TemperatureUnits? temperatureUnits,
    String? countryCode,
    String? description,
    int? code,
    String? locale,
  }) {
    return Weather(
      condition: condition ?? this.condition,
      lastUpdatedDateTime: lastUpdatedDateTime ?? this.lastUpdatedDateTime,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
      temperatureUnits: temperatureUnits ?? this.temperatureUnits,
      countryCode: countryCode ?? this.countryCode,
      description: description ?? this.description,
      code: code ?? this.code,
      locale: locale ?? this.locale,
    );
  }

  String get formattedTemperature {
    return '''${temperature.value.toStringAsPrecision(2)}°${temperatureUnits.isCelsius ? 'C' : 'F'}''';
  }

  String get emoji => condition.toEmoji;

  bool get isUnknown {
    return condition.isUnknown || location.isEmpty;
  }

  bool get needsRefresh {
    final int difference = DateTime.now()
        .difference(
          lastUpdatedDateTime ?? DateTime(0),
        )
        .inMinutes;
    return difference > constants.weatherRefreshDelayMinutes;
  }

  /// Output: e.g., "Dec 12, Monday at 03:45 PM".
  String getFormattedLastUpdatedDateTime(String locale) {
    if (lastUpdatedDateTime != null) {
      try {
        final DateFormat formatter = DateFormat(
          'MMM dd, EEEE \'-\' hh:mm a',
          locale,
        );
        return formatter.format(lastUpdatedDateTime ?? DateTime(0));
      } catch (e, stackTrace) {
        debugPrint(
          'Weather.formattedLastUpdatedDateTime:\n'
          'Failed to format date with locale "$countryCode".\n'
          'Falling back to default locale formatting.\n'
          'Error: ${e.toString()}\n'
          'StackTrace: $stackTrace',
        );
        final DateFormat formatter = DateFormat(
          'MMM dd, EEEE \'at\' hh:mm a',
        );
        return formatter.format(lastUpdatedDateTime ?? DateTime(0));
      }
    } else {
      return translate('never_updated');
    }
  }

  bool get neverUpdated => lastUpdatedDateTime == null;

  bool get isNotEmpty => this != empty;

  bool get isEmpty => this == empty;

  int get remainingMinutes {
    final int difference = constants.weatherRefreshDelayMinutes -
        DateTime.now().difference(lastUpdatedDateTime ?? DateTime(0)).inMinutes;

    return difference > 0 ? difference : 0;
  }

  String get locationName => location.name.isEmpty
      ? '${translate('lat')}: ${location.latitude.toStringAsFixed(2)}, '
          '${translate('lon')}: ${location.longitude.toStringAsFixed(2)}'
      : location.name;

  bool get isCelsius => temperatureUnits.isCelsius;
}
