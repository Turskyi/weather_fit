import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/temperature.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather.g.dart';

@JsonSerializable()
class Weather extends Equatable {
  const Weather({
    required this.condition,
    this.lastUpdated,
    required this.city,
    required this.temperature,
    required this.temperatureUnits,
    required this.countryCode,
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
      lastUpdated: parsedDateTime,
      city: weather.location,
      temperature: Temperature(value: weather.temperature),
      temperatureUnits: TemperatureUnits.celsius,
      countryCode: weather.countryCode,
    );
  }

  final WeatherCondition condition;
  final DateTime? lastUpdated;
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
        lastUpdated,
        city,
        temperature,
        temperatureUnits,
        countryCode,
      ];

  @override
  String toString() {
    return 'Weather{condition: $condition, lastUpdated: $lastUpdated, '
        'city: $city, temperature: $temperature, '
        'temperatureUnits: $temperatureUnits}';
  }

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  Weather copyWith({
    WeatherCondition? condition,
    DateTime? lastUpdated,
    String? city,
    Temperature? temperature,
    TemperatureUnits? temperatureUnits,
    String? countryCode,
  }) =>
      Weather(
        condition: condition ?? this.condition,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        city: city ?? this.city,
        temperature: temperature ?? this.temperature,
        temperatureUnits: temperatureUnits ?? this.temperatureUnits,
        countryCode: countryCode ?? this.countryCode,
      );

  String get formattedTemperature =>
      '''${temperature.value.toStringAsPrecision(2)}°${temperatureUnits.isCelsius ? 'C' : 'F'}''';

  String get emoji => condition.toEmoji;

  bool get isUnknown => condition == WeatherCondition.unknown || city.isEmpty;
}
