import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_fit/data/repositories/ai_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/enums/weather_status.dart';
import 'package:weather_fit/entities/temperature.dart';
import 'package:weather_fit/entities/weather.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository;

part 'weather_cubit.g.dart';
part 'weather_state.dart';

class WeatherCubit extends HydratedCubit<WeatherState> {
  WeatherCubit(this._weatherRepository, this._aiRepository)
      : super(
          WeatherState(
            status: kIsWeb ? WeatherStatus.initial : WeatherStatus.loading,
          ),
        );

  final WeatherRepository _weatherRepository;
  final AiRepository _aiRepository;

  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) {
      emit(state.copyWith(status: WeatherStatus.initial));
      return;
    }
    emit(state.copyWith(status: WeatherStatus.loading));
    try {
      final Weather weather = Weather.fromRepository(
        await _weatherRepository.getWeather(city),
      );
      final TemperatureUnits units = state.weather.temperatureUnits;
      final double value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(
        state.copyWith(
          status: WeatherStatus.success,
          weather: weather.copyWith(
            temperature: Temperature(value: value),
            temperatureUnits: units,
          ),
        ),
      );
      String imageUrl =
          await _aiRepository.getImageUrlFromAiAsFuture(state.weather);
      emit(
        state.copyWith(outfitImageUrl: imageUrl),
      );
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }

  Future<void> refreshWeather() async {
    if (!state.status.isSuccess) {
      emit(state.copyWith(status: WeatherStatus.initial));
      return;
    }
    if (state.weather == Weather.empty) {
      emit(state.copyWith(status: WeatherStatus.initial));
      return;
    }
    try {
      final Weather weather = Weather.fromRepository(
        await _weatherRepository.getWeather(state.weather.location),
      );
      final TemperatureUnits units = state.weather.temperatureUnits;
      final double value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(
        state.copyWith(
          status: WeatherStatus.success,
          weather: weather.copyWith(
            temperature: Temperature(value: value),
            temperatureUnits: units,
          ),
        ),
      );
    } on Exception {
      emit(state);
    }
  }

  void toggleUnits() {
    final TemperatureUnits units = state.weather.temperatureUnits.isFahrenheit
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;

    if (!state.status.isSuccess) {
      emit(
        state.copyWith(
          weather: state.weather.copyWith(temperatureUnits: units),
        ),
      );
      return;
    }

    final Weather weather = state.weather;

    if (weather != Weather.empty) {
      final Temperature temperature = weather.temperature;
      final double value = units.isCelsius
          ? temperature.value.toCelsius()
          : temperature.value.toFahrenheit();

      emit(
        state.copyWith(
          weather: weather.copyWith(
            temperature: Temperature(value: value),
            temperatureUnits: units,
          ),
        ),
      );
    }
  }

  @override
  WeatherState fromJson(Map<String, dynamic> json) =>
      WeatherState.fromJson(json);

  @override
  Map<String, dynamic> toJson(WeatherState state) => state.toJson();
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;

  double toCelsius() => (this - 32) * 5 / 9;
}
