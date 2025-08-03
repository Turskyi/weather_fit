import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
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
import 'package:weather_fit/services/home_widget_service.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather_bloc.g.dart';
part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends HydratedBloc<WeatherEvent, WeatherState> {
  WeatherBloc(
    this._weatherRepository,
    this._outfitRepository,
    this._localDataSource,
    this._homeWidgetService,
    String _locale,
  ) : super(WeatherInitial(locale: _locale)) {
    on<FetchWeather>(_onFetchWeather);
    on<RefreshWeather>(_onRefreshWeather);
    on<ToggleUnits>(_onToggleUnits);
    on<UpdateWeatherOnMobileHomeScreenEvent>(_updateWeatherOnMobileHomeScreen);
    on<GetOutfitEvent>(_onOutfitRecommendationRequested);
  }

  final WeatherRepository _weatherRepository;
  final OutfitRepository _outfitRepository;
  final LocalDataSource _localDataSource;
  final HomeWidgetService _homeWidgetService;

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
    final String savedLocale = _localDataSource.getLanguageIsoCode();
    if (eventLocation.isEmpty) {
      emit(WeatherInitial(locale: savedLocale));
      return;
    }

    emit(WeatherLoadingState(locale: savedLocale, weather: state.weather));
    try {
      final WeatherDomain domainWeather = await _getWeatherByLocation(
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
          locale: savedLocale,
          weather: updatedWeather,
          outfitRecommendation: outfitRecommendation,
        ),
      );

      if (state is WeatherSuccess) {
        final String assetPath = _outfitRepository.getOutfitImageAssetPath(
          weather,
        );

        emit((state as WeatherSuccess).copyWith(outfitAssetPath: assetPath));

        // Only add the event if it's NOT web AND NOT macOS.
        // For context, see issue:
        // https://github.com/ABausG/home_widget/issues/137.
        if (!kIsWeb && !Platform.isMacOS) {
          add(const UpdateWeatherOnMobileHomeScreenEvent());
        }
      } else {
        emit(
          WeatherSuccess(
            locale: savedLocale,
            weather: updatedWeather,
            outfitRecommendation: outfitRecommendation,
          ),
        );
      }
    } on Exception catch (e) {
      debugPrint('WeatherBloc _onFetchWeather Exception: $e.');
      final String stateOutfitRecommendation = state.outfitRecommendation;
      if (e is http.ClientException && kDebugMode && kIsWeb) {
        emit(
          LocalWebCorsFailure(
            locale: savedLocale,
            message: translate('error.cors'),
            outfitRecommendation: stateOutfitRecommendation,
          ),
        );
      } else {
        emit(
          WeatherFailure(
            locale: savedLocale,
            message: '$e',
            outfitRecommendation: stateOutfitRecommendation,
          ),
        );
      }
    }
  }

  FutureOr<void> _onRefreshWeather(
    RefreshWeather _,
    Emitter<WeatherState> emit,
  ) async {
    final Weather stateWeather = state.weather;
    final String stateOutfitRecommendation = state.outfitRecommendation;
    final String stateOutfitAssetPath = state.outfitAssetPath;
    final String savedLocale = _localDataSource.getLanguageIsoCode();
    if (state is! WeatherSuccess) {
      emit(
        WeatherInitial(
          locale: savedLocale,
          weather: stateWeather,
          outfitRecommendation: stateOutfitRecommendation,
          outfitAssetPath: stateOutfitAssetPath,
        ),
      );
      return;
    }

    if (stateWeather.isUnknown) {
      emit(WeatherInitial(locale: savedLocale));
      return;
    }

    emit(
      WeatherLoadingState(
        locale: savedLocale,
        weather: stateWeather,
        outfitRecommendation: stateOutfitRecommendation,
        outfitAssetPath: stateOutfitAssetPath,
      ),
    );

    try {
      final Location stateLocation = state.location;
      final WeatherDomain updatedWeather = await _getWeatherByLocation(
        stateLocation,
      );

      final Weather weather = Weather.fromRepository(updatedWeather);

      final TemperatureUnits units = stateWeather.temperatureUnits;

      final double temperatureValue = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      final String updatedOutfitRecommendation = _getOutfitRecommendation(
        weather,
      );

      emit(
        LoadingOutfitState(
          locale: savedLocale,
          weather: weather.copyWith(
            temperature: Temperature(value: temperatureValue),
            temperatureUnits: units,
          ),
          outfitRecommendation: updatedOutfitRecommendation,
          outfitAssetPath: _outfitRepository.getOutfitImageAssetPath(weather),
        ),
      );

      if (state is WeatherSuccess) {
        final String filePath = _outfitRepository.getOutfitImageAssetPath(
          weather,
        );

        emit((state as WeatherSuccess).copyWith(outfitAssetPath: filePath));

        // Only add the event if it's NOT web AND NOT macOS.
        // For context, see issue:
        // https://github.com/ABausG/home_widget/issues/137.
        if (!kIsWeb && !Platform.isMacOS) {
          add(const UpdateWeatherOnMobileHomeScreenEvent());
        }
      }
    } on Exception catch (e) {
      debugPrint('Failed to get weather: $e');
      emit(
        WeatherFailure(
          locale: savedLocale,
          message: '$e',
          outfitRecommendation: stateOutfitRecommendation,
          outfitAssetPath: stateOutfitAssetPath,
        ),
      );
    }
  }

  Future<WeatherDomain> _getWeatherByLocation(Location location) {
    return _weatherRepository.getWeatherByLocation(location);
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
      final Weather updatedWeather = weather.copyWith(
        temperature: Temperature(value: value),
        temperatureUnits: units,
      );

      emit((state as WeatherSuccess).copyWith(weather: updatedWeather));
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
      _homeWidgetService.setAppGroupId(constants.appleAppGroupId);

      _homeWidgetService.saveWidgetData<String>(
        HomeWidgetKey.textEmoji.stringValue,
        state.emoji,
      );

      _homeWidgetService.saveWidgetData<String>(
        HomeWidgetKey.textLocation.stringValue,
        state.locationName,
      );

      _homeWidgetService.saveWidgetData<String>(
        HomeWidgetKey.textTemperature.stringValue,
        state.formattedTemperature,
      );

      _homeWidgetService.saveWidgetData<String>(
        HomeWidgetKey.textLastUpdated.stringValue,
        '${translate('last_updated_on_label')}\n'
        '${state.formattedLastUpdatedDateTime}',
      );

      _homeWidgetService.saveWidgetData<String>(
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

      _homeWidgetService.saveWidgetData<String>(
        HomeWidgetKey.imageWeather.stringValue,
        filePath,
      );

      _homeWidgetService.updateWidget(
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
    final Weather eventWeather = event.weather;
    final Location eventLocation = eventWeather.location;

    final String savedLocale = _localDataSource.getLanguageIsoCode();

    if (eventWeather.isEmpty) {
      emit(WeatherInitial(locale: savedLocale));
      return;
    }
    final Weather localizedWeather = eventWeather.copyWith(
      location: eventLocation.copyWith(locale: savedLocale),
      locale: savedLocale,
    );
    emit(WeatherLoadingState(locale: savedLocale, weather: localizedWeather));
    try {
      final TemperatureUnits units = state.temperatureUnits;

      final Weather updatedWeather = localizedWeather.copyWith(
        temperature: Temperature(value: eventWeather.temperature.value),
        temperatureUnits: units,
      );

      final String outfitRecommendation = _getOutfitRecommendation(
        updatedWeather,
      );

      emit(
        LoadingOutfitState(
          locale: savedLocale,
          weather: updatedWeather,
          outfitRecommendation: outfitRecommendation,
        ),
      );

      if (state is WeatherSuccess) {
        final String assetPath = _outfitRepository.getOutfitImageAssetPath(
          eventWeather,
        );
        emit((state as WeatherSuccess).copyWith(outfitAssetPath: assetPath));
        // Only add the event if it's NOT web AND NOT macOS.
        // For context, see issue:
        // https://github.com/ABausG/home_widget/issues/137.
        if (!kIsWeb && !Platform.isMacOS) {
          add(const UpdateWeatherOnMobileHomeScreenEvent());
        }
        final bool isLocationSaved = await _localDataSource.saveLocation(
          eventWeather.location,
        );

        if (isLocationSaved) {
          //   TODO: add notification to user that location has been saved.
        }
      } else {
        emit(
          WeatherSuccess(
            locale: savedLocale,
            weather: updatedWeather,
            outfitRecommendation: outfitRecommendation,
          ),
        );
      }
    } on Exception catch (e) {
      debugPrint('WeatherBloc _onOutfitRecommendationRequested Exception: $e');
      final String stateOutfitRecommendation = state.outfitRecommendation;
      if (e is http.ClientException && kDebugMode && kIsWeb) {
        emit(
          LocalWebCorsFailure(
            locale: savedLocale,
            message: translate('error.cors'),
            outfitRecommendation: stateOutfitRecommendation,
          ),
        );
      } else {
        emit(
          WeatherFailure(
            locale: savedLocale,
            message: '$e',
            outfitRecommendation: stateOutfitRecommendation,
          ),
        );
      }
    }
  }
}
