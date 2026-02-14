import 'package:equatable/equatable.dart';

class SavedPlan extends Equatable {
  SavedPlan({required this.cityName, required DateTime date})
    : date = DateTime(date.year, date.month, date.day);

  factory SavedPlan.fromJson(Map<String, Object?> json) {
    return SavedPlan(
      cityName: json['city_name'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  final String cityName;
  final DateTime date;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'city_name': cityName,
      'date': date.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => <Object?>[cityName, date];
}
