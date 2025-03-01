import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:weather_fit/data/repositories/ai_repository.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
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
    on<UpdateWeatherOnMobileHomeScreenEvent>(
      _onUpdateWeatherOnMobileHomeScreen,
    );
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
    final String eventLocation = event.city;
    if (eventLocation.isEmpty) {
      emit(const WeatherInitial());
      return;
    }

    if (state is WeatherSuccess &&
        eventLocation == state.location &&
        !state.needsRefresh) {
      final String message = 'Same location.\n'
          'Wait ${state.remainingMinutes} minutes '
          'to get updated weather and outfit.';

      emit(
        (state as WeatherSuccess).copyWith(snackbarMessage: message),
      );
    } else {
      emit(const WeatherLoadingState());
      try {
        final String location = event.city;

        final WeatherDomain domainWeather = await _weatherRepository.getWeather(
          location,
        );

        final Weather weather = Weather.fromRepository(domainWeather);

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
          if (kIsWeb) {
            emit(
              (state as WeatherSuccess).copyWith(outfitImageUrl: imageUrl),
            );
          } else {
            final String filePath = await _downloadAndSaveImage(imageUrl);

            emit(
              (state as WeatherSuccess).copyWith(
                outfitImageUrl: imageUrl,
                outfitImagePath: filePath,
              ),
            );
            add(const UpdateWeatherOnMobileHomeScreenEvent());
          }
        }
      } on Exception catch (e) {
        emit(WeatherFailure(message: '$e'));
      }
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

      final String imageUrl = await _aiRepository.getImageUrlFromAiAsFuture(
        state.weather,
      );

      if (state is WeatherSuccess) {
        if (kIsWeb) {
          emit(
            (state as WeatherSuccess).copyWith(outfitImageUrl: imageUrl),
          );
        } else {
          final String filePath = await _downloadAndSaveImage(imageUrl);
          emit(
            (state as WeatherSuccess).copyWith(
              outfitImageUrl: imageUrl,
              outfitImagePath: filePath,
            ),
          );

          add(const UpdateWeatherOnMobileHomeScreenEvent());
        }
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

  Future<String> _downloadAndSaveImage(String imageUrl) async {
    final http.Response response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == HttpStatus.ok) {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/outfit_image.png';

      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } else {
      throw Exception('Failed to download image');
    }
  }

  FutureOr<void> _onUpdateWeatherOnMobileHomeScreen(
    UpdateWeatherOnMobileHomeScreenEvent event,
    Emitter<WeatherState> emit,
  ) async {
    if (kIsWeb) return;

    try {
      // Set the group ID.
      HomeWidget.setAppGroupId(constants.appGroupId);

      // Save weather data to the widget.
      HomeWidget.saveWidgetData<String>('text_emoji', state.weather.emoji);
      HomeWidget.saveWidgetData<String>('text_location', state.weather.city);
      HomeWidget.saveWidgetData<String>(
        'text_temperature',
        state.weather.formattedTemperature,
      );
      HomeWidget.saveWidgetData<String>(
        'text_last_updated',
        'Last Updated on ${state.weather.formattedLastUpdatedDateTime}',
      );

      String imagePath = state.outfitImagePath;

      if (imagePath.isEmpty) {
        if (state.outfitImageUrl.isNotEmpty) {
          imagePath = await _downloadAndSaveImage(state.outfitImageUrl);
        } else if (state.weather.isNotEmpty) {
          final String imageUrl = await _aiRepository.getImageUrlFromAiAsFuture(
            state.weather,
          );
          imagePath = await _downloadAndSaveImage(imageUrl);
        } else {
          emit(const WeatherInitial());
        }
      }

      if (imagePath.isNotEmpty) {
        // Save the image path if it's valid.
        HomeWidget.saveWidgetData<String>('image_weather', imagePath);
      }

      // Update the widget.
      HomeWidget.updateWidget(
        iOSName: constants.iOSWidgetName,
        androidName: constants.androidWidgetName,
      );
    } catch (e) {
      debugPrint('Failed to update home screen widget: $e');
    }
  }
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;

  double toCelsius() => (this - 32) * 5 / 9;
}
