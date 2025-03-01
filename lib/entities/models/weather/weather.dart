import 'package:equatable/equatable.dart';
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
    required this.city,
    required this.temperature,
    required this.temperatureUnits,
    required this.countryCode,
    this.lastUpdatedDateTime,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  factory Weather.fromRepository(WeatherDomain weather) {
    DateTime now = DateTime.now();
    String formattedNow = DateFormat('yyyy-MM-dd HH:mm').format(now);
    DateTime parsedDateTime =
        DateFormat('yyyy-MM-dd HH:mm').parse(formattedNow);

    return Weather(
      condition: weather.condition,
      lastUpdatedDateTime: parsedDateTime,
      city: weather.location,
      temperature: Temperature(value: weather.temperature),
      temperatureUnits: TemperatureUnits.celsius,
      countryCode: weather.countryCode,
    );
  }

  final WeatherCondition condition;
  final DateTime? lastUpdatedDateTime;
  final String city;
  final Temperature temperature;
  final TemperatureUnits temperatureUnits;
  final String countryCode;

  static const Weather empty = Weather(
    condition: WeatherCondition.unknown,
    temperature: Temperature(value: 0),
    city: '',
    temperatureUnits: TemperatureUnits.celsius,
    countryCode: '',
  );

  @override
  List<Object?> get props => <Object?>[
        condition,
        lastUpdatedDateTime,
        city,
        temperature,
        temperatureUnits,
        countryCode,
      ];

  @override
  String toString() {
    return 'Weather{'
        'condition: $condition, '
        'city: $city, '
        'temperature: $temperature, '
        'temperatureUnits: $temperatureUnits, '
        'countryCode: $countryCode,'
        '}';
  }

  Map<String, Object?> toJson() => _$WeatherToJson(this);

  Weather copyWith({
    WeatherCondition? condition,
    DateTime? lastUpdatedDateTime,
    String? city,
    Temperature? temperature,
    TemperatureUnits? temperatureUnits,
    String? countryCode,
  }) =>
      Weather(
        condition: condition ?? this.condition,
        lastUpdatedDateTime: lastUpdatedDateTime ?? this.lastUpdatedDateTime,
        city: city ?? this.city,
        temperature: temperature ?? this.temperature,
        temperatureUnits: temperatureUnits ?? this.temperatureUnits,
        countryCode: countryCode ?? this.countryCode,
      );

  String get formattedTemperature =>
      '''${temperature.value.toStringAsPrecision(2)}°${temperatureUnits.isCelsius ? 'C' : 'F'}''';

  String get emoji => condition.toEmoji;

  bool get isUnknown => condition == WeatherCondition.unknown || city.isEmpty;

  bool get needsRefresh {
    final int difference = DateTime.now()
        .difference(
          lastUpdatedDateTime ?? DateTime(0),
        )
        .inMinutes;
    return difference > constants.weatherRefreshDelayMinutes;
  }

  /// Output: e.g., "Dec 12, Monday at 03:45 PM"
  String get formattedLastUpdatedDateTime {
    if (lastUpdatedDateTime != null) {
      final DateFormat formatter = DateFormat('MMM dd, EEEE \'at\' hh:mm a');
      return formatter.format(lastUpdatedDateTime ?? DateTime(0));
    } else {
      return 'Never updated';
    }
  }

  bool get neverUpdated => lastUpdatedDateTime == null;

  bool get isNotEmpty => this != empty;

  int get remainingMinutes {
    final int difference = constants.weatherRefreshDelayMinutes -
        DateTime.now().difference(lastUpdatedDateTime ?? DateTime(0)).inMinutes;

    return difference > 0 ? difference : 0;
  }
}
