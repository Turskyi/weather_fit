import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/res/home_widget_keys.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather_bloc.g.dart';
part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends HydratedBloc<WeatherEvent, WeatherState> {
  WeatherBloc(
    this._weatherRepository,
    this._outfitRepository,
    this._localDataSource,
  ) : super(const WeatherInitial()) {
    on<FetchWeather>(_onFetchWeather);
    on<RefreshWeather>(_onRefreshWeather);
    on<ToggleUnits>(_onToggleUnits);
    on<UpdateWeatherOnMobileHomeScreenEvent>(_updateWeatherOnMobileHomeScreen);
    on<GetOutfitEvent>(_onOutfitRecommendationRequested);
  }

  final WeatherRepository _weatherRepository;
  final OutfitRepository _outfitRepository;
  final LocalDataSource _localDataSource;

  @override
  WeatherSuccess fromJson(Map<String, Object?> json) {
    return WeatherSuccess.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(Object? state) {
    if (state is WeatherSuccess) {
      return state.toJson();
    } else {
      return <String, Object?>{};
    }
  }

  FutureOr<void> _onFetchWeather(
    FetchWeather event,
    Emitter<WeatherState> emit,
  ) async {
    final Location eventLocation = event.location;

    if (eventLocation.isEmpty) {
      emit(const WeatherInitial());
      return;
    }

    emit(const WeatherLoadingState());
    try {
      final WeatherDomain domainWeather =
          await _weatherRepository.getWeatherByLocation(
        eventLocation,
      );

      final Weather weather = Weather.fromRepository(domainWeather);

      final TemperatureUnits units = state.temperatureUnits;

      final double value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      final Weather updatedWeather = weather.copyWith(
        temperature: Temperature(value: value),
        temperatureUnits: units,
      );

      final String outfitRecommendation = _getOutfitRecommendation(
        updatedWeather,
      );

      emit(
        LoadingOutfitState(
          weather: updatedWeather,
          outfitRecommendation: outfitRecommendation,
        ),
      );

      if (state is WeatherSuccess) {
        final String assetPath = _outfitRepository.getOutfitImageAssetPath(
          weather,
        );

        emit(
          (state as WeatherSuccess).copyWith(outfitAssetPath: assetPath),
        );

        // Only add the event if it's NOT web AND NOT macOS.
        // For context, see issue:
        // https://github.com/ABausG/home_widget/issues/137.
        if (!kIsWeb && !Platform.isMacOS) {
          add(const UpdateWeatherOnMobileHomeScreenEvent());
        }
      } else {
        emit(
          WeatherSuccess(
            weather: updatedWeather,
            outfitRecommendation: outfitRecommendation,
          ),
        );
      }
    } on Exception catch (e) {
      if (e is http.ClientException && kDebugMode && kIsWeb) {
        emit(
          LocalWebCorsFailure(
            message: translate('error.cors'),
            outfitRecommendation: state.outfitRecommendation,
          ),
        );
      } else {
        emit(
          WeatherFailure(
            message: '$e',
            outfitRecommendation: state.outfitRecommendation,
          ),
        );
      }
    }
  }

  FutureOr<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    if (state is! WeatherSuccess) {
      emit(
        WeatherInitial(
          weather: state.weather,
          outfitRecommendation: state.outfitRecommendation,
          outfitAssetPath: state.outfitAssetPath,
        ),
      );
      return;
    }

    if (state.weather.isUnknown) {
      emit(const WeatherInitial());
      return;
    }

    emit(
      WeatherLoadingState(
        weather: state.weather,
        outfitRecommendation: state.outfitRecommendation,
        outfitAssetPath: state.outfitAssetPath,
      ),
    );

    try {
      final WeatherDomain updatedWeather =
          await _weatherRepository.getWeatherByLocation(
        state.location,
      );

      final Weather weather = Weather.fromRepository(updatedWeather);

      final TemperatureUnits units = state.weather.temperatureUnits;

      final double temperatureValue = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      final String outfitRecommendation = _getOutfitRecommendation(weather);

      emit(
        LoadingOutfitState(
          weather: weather.copyWith(
            temperature: Temperature(value: temperatureValue),
            temperatureUnits: units,
          ),
          outfitRecommendation: outfitRecommendation,
          outfitAssetPath: _outfitRepository.getOutfitImageAssetPath(weather),
        ),
      );

      if (state is WeatherSuccess) {
        final String filePath = _outfitRepository.getOutfitImageAssetPath(
          weather,
        );

        emit(
          (state as WeatherSuccess).copyWith(outfitAssetPath: filePath),
        );

        // Only add the event if it's NOT web AND NOT macOS.
        // For context, see issue:
        // https://github.com/ABausG/home_widget/issues/137.
        if (!kIsWeb && !Platform.isMacOS) {
          add(const UpdateWeatherOnMobileHomeScreenEvent());
        }
      }
    } on Exception catch (e) {
      emit(
        WeatherFailure(
          message: '$e',
          outfitRecommendation: state.outfitRecommendation,
          outfitAssetPath: state.outfitAssetPath,
        ),
      );
    }
  }

  void _onToggleUnits(ToggleUnits _, Emitter<WeatherState> emit) {
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

  Future<String> _downloadAndSaveImage(String assetPath) async {
    return _outfitRepository.downloadAndSaveImage(assetPath);
  }

  FutureOr<void> _updateWeatherOnMobileHomeScreen(
    UpdateWeatherOnMobileHomeScreenEvent event,
    Emitter<WeatherState> emit,
  ) async {
    // Check if the platform is web OR macOS. If so, return early.
    // See issue: https://github.com/ABausG/home_widget/issues/137.
    if (kIsWeb || (!kIsWeb && Platform.isMacOS)) {
      return;
    }

    try {
      // Set the group ID.
      HomeWidget.setAppGroupId(constants.appleAppGroupId);

      // Save weather data to the widget.
      HomeWidget.saveWidgetData<String>(
        HomeWidgetKey.textEmoji.stringValue,
        state.emoji,
      );

      HomeWidget.saveWidgetData<String>(
        HomeWidgetKey.textLocation.stringValue,
        state.locationName,
      );

      HomeWidget.saveWidgetData<String>(
        HomeWidgetKey.textTemperature.stringValue,
        state.formattedTemperature,
      );

      HomeWidget.saveWidgetData<String>(
        HomeWidgetKey.textLastUpdated.stringValue,
        '${translate(
          'last_updated_on_label',
        )}\n${state.formattedLastUpdatedDateTime}',
      );

      HomeWidget.saveWidgetData<String>(
        HomeWidgetKey.textRecommendation.stringValue,
        state.outfitRecommendation,
      );

      String assetPath = state.outfitAssetPath;
      if (assetPath.isEmpty) {
        final Weather weather = state.weather;
        if (weather.isNotEmpty) {
          assetPath = _outfitRepository.getOutfitImageAssetPath(weather);
        }
      }
      final String filePath = await _downloadAndSaveImage(assetPath);

      // Save the image path if it's valid.
      HomeWidget.saveWidgetData<String>(
        HomeWidgetKey.imageWeather.stringValue,
        filePath,
      );

      // Update the widget.
      HomeWidget.updateWidget(
        iOSName: constants.iOSWidgetName,
        androidName: constants.androidWidgetName,
      );
    } catch (e) {
      debugPrint('Failed to update home screen widget: $e');
    }
  }

  String _getOutfitRecommendation(Weather weather) {
    return _outfitRepository.getOutfitRecommendation(weather);
  }

  FutureOr<void> _onOutfitRecommendationRequested(
    GetOutfitEvent event,
    Emitter<WeatherState> emit,
  ) async {
    final Weather weather = event.weather;

    if (weather.isEmpty) {
      emit(const WeatherInitial());
      return;
    }

    emit(const WeatherLoadingState());
    try {
      final TemperatureUnits units = state.temperatureUnits;

      final double temperatureValue = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      final Weather updatedWeather = weather.copyWith(
        temperature: Temperature(value: temperatureValue),
        temperatureUnits: units,
      );

      final String outfitRecommendation = _getOutfitRecommendation(
        updatedWeather,
      );

      emit(
        LoadingOutfitState(
          weather: updatedWeather,
          outfitRecommendation: outfitRecommendation,
        ),
      );

      if (state is WeatherSuccess) {
        final String assetPath = _outfitRepository.getOutfitImageAssetPath(
          weather,
        );
        emit(
          (state as WeatherSuccess).copyWith(outfitAssetPath: assetPath),
        );
        // Only add the event if it's NOT web AND NOT macOS.
        // For context, see issue:
        // https://github.com/ABausG/home_widget/issues/137.
        if (!kIsWeb && !Platform.isMacOS) {
          add(const UpdateWeatherOnMobileHomeScreenEvent());
        }
        final bool isLocationSaved = await _localDataSource.saveLocation(
          weather.location,
        );
        if (isLocationSaved) {
          //   TODO: add notification to user that location has been saved.
        }
      } else {
        emit(
          WeatherSuccess(
            weather: updatedWeather,
            outfitRecommendation: outfitRecommendation,
          ),
        );
      }
    } on Exception catch (e) {
      if (e is http.ClientException && kDebugMode && kIsWeb) {
        emit(
          LocalWebCorsFailure(
            message: translate('error.cors'),
            outfitRecommendation: state.outfitRecommendation,
          ),
        );
      } else {
        emit(
          WeatherFailure(
            message: '$e',
            outfitRecommendation: state.outfitRecommendation,
          ),
        );
      }
    }
  }
}
