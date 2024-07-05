import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:weather_fit/data/repositories/ai_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather_bloc.g.dart';
part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends HydratedBloc<WeatherEvent, WeatherState> {
  WeatherBloc(this._weatherRepository, this._aiRepository)
      : super(const WeatherInitial()) {
    on<FetchWeather>(_onFetchWeather);
    on<RefreshWeather>(_onRefreshWeather);
    on<ToggleUnits>(_onToggleUnits);
  }

  final WeatherRepository _weatherRepository;
  final AiRepository _aiRepository;

  @override
  WeatherSuccess fromJson(Map<String, dynamic> json) =>
      WeatherSuccess.fromJson(json);

  @override
  Map<String, dynamic> toJson(dynamic state) => state.toJson();

  FutureOr<void> _onFetchWeather(
    FetchWeather event,
    Emitter<WeatherState> emit,
  ) async {
    if (event.city.isEmpty) {
      emit(const WeatherInitial());
      return;
    }
    emit(const WeatherLoadingState());
    try {
      final Weather weather = Weather.fromRepository(
        await _weatherRepository.getWeather(event.city),
      );

      final TemperatureUnits units = state.weather.temperatureUnits;

      final double value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      final Weather updatedWeather = weather.copyWith(
        temperature: Temperature(value: value),
        temperatureUnits: units,
      );

      emit(LoadingOutfitState(weather: updatedWeather));

      final String imageUrl = await _aiRepository.getImageUrlFromAiAsFuture(
        state.weather,
      );

      if (state is WeatherSuccess) {
        emit((state as WeatherSuccess).copyWith(outfitImageUrl: imageUrl));
      }
    } on Exception catch (e) {
      emit(WeatherFailure(message: '$e'));
    }
  }

  FutureOr<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    if (state is! WeatherSuccess) {
      emit(WeatherInitial(weather: state.weather));
      return;
    }

    if (state.weather.isUnknown) {
      emit(const WeatherInitial());
      return;
    }
    emit(
      WeatherLoadingState(
        weather: state.weather,
        outfitImageUrl: state.outfitImageUrl,
      ),
    );
    try {
      final WeatherDomain updatedWeather = await _weatherRepository.getWeather(
        state.weather.city,
      );

      final Weather weather = Weather.fromRepository(updatedWeather);

      final TemperatureUnits units = state.weather.temperatureUnits;
      final double value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(
        LoadingOutfitState(
          weather: weather.copyWith(
            temperature: Temperature(value: value),
            temperatureUnits: units,
          ),
        ),
      );

      String imageUrl = await _aiRepository.getImageUrlFromAiAsFuture(
        state.weather,
      );

      if (state is WeatherSuccess) {
        emit((state as WeatherSuccess).copyWith(outfitImageUrl: imageUrl));
      }
    } on Exception catch (e) {
      emit(WeatherFailure(message: '$e'));
    }
  }

  void _onToggleUnits(_, Emitter<WeatherState> emit) {
    final TemperatureUnits units = state.weather.temperatureUnits.isFahrenheit
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;
    final Weather weather = state.weather;
    final Temperature temperature = weather.temperature;
    final double value = units.isCelsius
        ? temperature.value.toCelsius()
        : temperature.value.toFahrenheit();

    if (state is WeatherSuccess) {
      emit(
        (state as WeatherSuccess).copyWith(
          weather: weather.copyWith(
            temperature: Temperature(value: value),
            temperatureUnits: units,
          ),
        ),
      );
    } else if (state is WeatherInitial) {
      emit(
        (state as WeatherInitial).copyWith(
          weather: weather.copyWith(
            temperature: Temperature(value: value),
            temperatureUnits: units,
          ),
        ),
      );
    }
  }
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;

  double toCelsius() => (this - 32) * 5 / 9;
}
