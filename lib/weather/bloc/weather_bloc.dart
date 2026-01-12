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
import 'package:weather_fit/entities/enums/weather_fetch_origin.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/extensions/double_extension.dart';
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
  ) : super(WeatherInitial(locale: _localDataSource.getLanguageIsoCode())) {
    on<FetchWeather>(_onFetchWeather);
    on<RefreshWeather>(_onRefreshWeather);
    on<ToggleUnits>(_onToggleUnits);
    on<GetOutfitEvent>(_onOutfitRecommendationRequested);
    on<FetchDailyForecast>(_onFetchDailyForecast);
    on<UpdateWeatherOnMobileHomeScreenEvent>(_updateWeatherOnMobileHomeScreen);
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
      emit(
        WeatherInitial(locale: savedLocale, dailyForecast: state.dailyForecast),
      );
      return;
    }

    emit(
      WeatherLoadingState(
        locale: savedLocale,
        weather: state.weather,
        dailyForecast: state.dailyForecast,
      ),
    );
    try {
      final DailyForecastDomain dailyForecast = await _weatherRepository
          .getDailyForecast(eventLocation);

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
          dailyForecast: dailyForecast,
        ),
      );

      final WeatherState currentState = state;
      if (currentState is WeatherSuccess) {
        final OutfitImage outfitImage = await _outfitRepository.getOutfitImage(
          weather,
        );

        emit(currentState.copyWith(outfitImage: outfitImage));

        final WeatherFetchOrigin eventOrigin = event.origin;
        // Only add the event if it's NOT web AND NOT macOS.
        // For context, see issue:
        // https://github.com/ABausG/home_widget/issues/137.
        if (!kIsWeb && !Platform.isMacOS && eventOrigin.isNotWearable) {
          add(UpdateWeatherOnMobileHomeScreenEvent(eventOrigin));
        }
      } else {
        final OutfitImage outfitImage = await _outfitRepository.getOutfitImage(
          weather,
        );
        emit(
          WeatherSuccess(
            locale: savedLocale,
            weather: updatedWeather,
            outfitRecommendation: outfitRecommendation,
            outfitImage: outfitImage,
            dailyForecast: dailyForecast,
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
            dailyForecast: state.dailyForecast,
          ),
        );
      } else {
        emit(
          WeatherFailure(
            locale: savedLocale,
            message: '$e',
            outfitRecommendation: stateOutfitRecommendation,
            dailyForecast: state.dailyForecast,
          ),
        );
      }
    }
  }

  FutureOr<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    final Weather stateWeather = state.weather;
    final String stateOutfitRecommendation = state.outfitRecommendation;
    final OutfitImage stateOutfitImage = state.outfitImage;
    final String savedLocale = _localDataSource.getLanguageIsoCode();
    if (state is! WeatherSuccess) {
      emit(
        WeatherInitial(
          locale: savedLocale,
          weather: stateWeather,
          outfitRecommendation: stateOutfitRecommendation,
          outfitImage: stateOutfitImage,
          dailyForecast: state.dailyForecast,
        ),
      );
      return;
    }

    if (stateWeather.isUnknown) {
      emit(
        WeatherInitial(locale: savedLocale, dailyForecast: state.dailyForecast),
      );
      return;
    }

    emit(
      WeatherLoadingState(
        locale: savedLocale,
        weather: stateWeather,
        outfitRecommendation: stateOutfitRecommendation,
        outfitImage: stateOutfitImage,
        dailyForecast: state.dailyForecast,
      ),
    );

    try {
      final Location stateLocation = state.location;
      final WeatherDomain updatedWeather = await _getWeatherByLocation(
        stateLocation,
      );

      final Weather weather = Weather.fromRepository(updatedWeather);

      final DailyForecastDomain dailyForecast = await _weatherRepository
          .getDailyForecast(stateLocation);

      final TemperatureUnits units = stateWeather.temperatureUnits;

      final double temperatureValue = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      final String updatedOutfitRecommendation = _getOutfitRecommendation(
        weather,
      );

      final OutfitImage updatedOutfitImage = await _outfitRepository
          .getOutfitImage(weather);

      emit(
        LoadingOutfitState(
          locale: savedLocale,
          weather: weather.copyWith(
            temperature: Temperature(value: temperatureValue),
            temperatureUnits: units,
          ),
          outfitRecommendation: updatedOutfitRecommendation,
          outfitImage: updatedOutfitImage,
          dailyForecast: dailyForecast,
        ),
      );

      if (state is WeatherSuccess) {
        emit(
          (state as WeatherSuccess).copyWith(outfitImage: updatedOutfitImage),
        );

        final WeatherFetchOrigin eventOrigin = event.origin;
        // Only add the event if it's NOT web AND NOT macOS.
        // For context, see issue:
        // https://github.com/ABausG/home_widget/issues/137.
        if (!kIsWeb && !Platform.isMacOS && eventOrigin.isNotWearable) {
          add(UpdateWeatherOnMobileHomeScreenEvent(eventOrigin));
        }
      }
    } on Exception catch (e) {
      debugPrint('Failed to get weather: $e');
      emit(
        WeatherFailure(
          locale: savedLocale,
          message: '$e',
          outfitRecommendation: stateOutfitRecommendation,
          outfitImage: stateOutfitImage,
          dailyForecast: state.dailyForecast,
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
      emit(
        WeatherInitial(locale: savedLocale, dailyForecast: state.dailyForecast),
      );
      return;
    }
    final Weather localizedWeather = eventWeather.copyWith(
      location: eventLocation.copyWith(locale: savedLocale),
      locale: savedLocale,
    );
    emit(
      WeatherLoadingState(
        locale: savedLocale,
        weather: localizedWeather,
        dailyForecast: state.dailyForecast,
      ),
    );
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
          dailyForecast: state.dailyForecast,
        ),
      );

      if (state is WeatherSuccess) {
        final OutfitImage outfitImage = await _outfitRepository.getOutfitImage(
          eventWeather,
        );
        emit((state as WeatherSuccess).copyWith(outfitImage: outfitImage));
        final WeatherFetchOrigin eventOrigin = event.origin;
        // Only add the event if it's NOT web AND NOT macOS.
        // For context, see issue:
        // https://github.com/ABausG/home_widget/issues/137.
        if (!kIsWeb && !Platform.isMacOS && eventOrigin.isNotWearable) {
          add(UpdateWeatherOnMobileHomeScreenEvent(eventOrigin));
        }
        final bool isLocationSaved = await _localDataSource.saveLocation(
          eventWeather.location,
        );

        if (isLocationSaved) {
          //   TODO: add notification to user that location has been saved.
        }
      } else {
        final OutfitImage outfitImage = await _outfitRepository.getOutfitImage(
          eventWeather,
        );
        emit(
          WeatherSuccess(
            locale: savedLocale,
            weather: updatedWeather,
            outfitRecommendation: outfitRecommendation,
            outfitImage: outfitImage,
            dailyForecast: state.dailyForecast,
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
            dailyForecast: state.dailyForecast,
          ),
        );
      } else {
        emit(
          WeatherFailure(
            locale: savedLocale,
            message: '$e',
            outfitRecommendation: stateOutfitRecommendation,
            dailyForecast: state.dailyForecast,
          ),
        );
      }
    }
  }

  FutureOr<void> _onFetchDailyForecast(
    FetchDailyForecast event,
    Emitter<WeatherState> emit,
  ) async {
    final String savedLocale = _localDataSource.getLanguageIsoCode();
    emit(
      WeatherLoadingState(
        locale: savedLocale,
        weather: state.weather,
        dailyForecast: state.dailyForecast,
        outfitRecommendation: state.outfitRecommendation,
        outfitImage: state.outfitImage,
      ),
    );
    try {
      final DailyForecastDomain dailyForecast = await _weatherRepository
          .getDailyForecast(event.location);

      if (state is WeatherSuccess) {
        emit((state as WeatherSuccess).copyWith(dailyForecast: dailyForecast));
      } else {
        emit(
          WeatherSuccess(
            locale: savedLocale,
            weather: state.weather,
            dailyForecast: dailyForecast,
          ),
        );
      }
    } on Exception catch (e) {
      debugPrint('Failed to get daily forecast: $e');
      emit(
        WeatherFailure(
          locale: savedLocale,
          message: '$e',
          outfitRecommendation: state.outfitRecommendation,
          outfitImage: state.outfitImage,
          dailyForecast: state.dailyForecast,
        ),
      );
    }
  }

  FutureOr<void> _updateWeatherOnMobileHomeScreen(
    UpdateWeatherOnMobileHomeScreenEvent event,
    Emitter<WeatherState> emit,
  ) async {
    // Check the supported platforms https://pub.dev/packages/home_widget
    // See issue: https://github.com/ABausG/home_widget/issues/137.
    if (!kIsWeb &&
        !Platform.isMacOS &&
        (Platform.isAndroid || Platform.isIOS)) {
      try {
        final Weather weather = state.weather;
        final DailyForecastDomain? dailyForecastDomain = state.dailyForecast;

        await _homeWidgetService.updateHomeWidget(
          localDataSource: _localDataSource,
          weather: weather,
          outfitRepository: _outfitRepository,
          forecast:
              dailyForecastDomain ??
              const DailyForecastDomain(forecast: <ForecastItemDomain>[]),
        );
      } catch (e) {
        debugPrint('Failed to update home screen widget: $e');
      }
    }
  }
}
