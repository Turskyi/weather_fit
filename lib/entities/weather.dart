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
    required this.lastUpdated,
    required this.location,
    required this.temperature,
    required this.temperatureUnits,
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
      location: weather.location,
      temperature: Temperature(value: weather.temperature),
      temperatureUnits: TemperatureUnits.celsius,
    );
  }

  static final Weather empty = Weather(
    condition: WeatherCondition.unknown,
    lastUpdated: DateTime(0),
    temperature: const Temperature(value: 0),
    location: '',
    temperatureUnits: TemperatureUnits.celsius,
  );

  final WeatherCondition condition;
  final DateTime lastUpdated;
  final String location;
  final Temperature temperature;
  final TemperatureUnits temperatureUnits;

  @override
  List<Object> get props =>
      <Object>[condition, lastUpdated, location, temperature, temperatureUnits];

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  Weather copyWith({
    WeatherCondition? condition,
    DateTime? lastUpdated,
    String? location,
    Temperature? temperature,
    TemperatureUnits? temperatureUnits,
  }) =>
      Weather(
        condition: condition ?? this.condition,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        location: location ?? this.location,
        temperature: temperature ?? this.temperature,
        temperatureUnits: temperatureUnits ?? this.temperatureUnits,
      );

  String get formattedTemperature {
    return '''${temperature.value.toStringAsPrecision(2)}°${temperatureUnits.isCelsius ? 'C' : 'F'}''';
  }

  String get emoji => condition.toEmoji;
}
