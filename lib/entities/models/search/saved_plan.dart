import 'package:equatable/equatable.dart';
import 'package:weather_repository/weather_repository.dart';

class SavedPlan extends Equatable {
  SavedPlan({required this.cityName, required DateTime date, this.weather})
    : date = DateTime(date.year, date.month, date.day);

  factory SavedPlan.fromJson(Map<String, Object?> json) {
    return SavedPlan(
      cityName: json['city_name'] as String,
      date: DateTime.parse(json['date'] as String),
      weather: json['weather'] != null
          ? WeatherDomain.fromJson(json['weather'] as Map<String, Object?>)
          : null,
    );
  }

  final String cityName;
  final DateTime date;
  final WeatherDomain? weather;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'city_name': cityName,
      'date': date.toIso8601String(),
      'weather': weather?.toJson(),
    };
  }

  @override
  List<Object?> get props => <Object?>[cityName, date, weather];
}
