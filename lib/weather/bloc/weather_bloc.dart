import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:http/http.dart' as http;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/entities/enums/temperature_units.dart';
import 'package:weather_fit/entities/enums/weather_fetch_origin.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/extensions/date_time_extension.dart';
import 'package:weather_fit/res/extensions/double_extension.dart';
import 'package:weather_fit/services/home_widget_service.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather_bloc.g.dart';
part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends HydratedBloc<WeatherEvent, WeatherState> {
  WeatherBloc({
    required WeatherRepository weatherRepository,
    required OutfitRepository outfitRepository,
    required LocalDataSource localDataSource,
    required HomeWidgetService homeWidgetService,
  }) : _weatherRepository = weatherRepository,
       _outfitRepository = outfitRepository,
       _localDataSource = localDataSource,
       _homeWidgetService = homeWidgetService,
       super(
         WeatherInitial(
           locale: localDataSource.getLanguageIsoCode(),
           dailyForecast: const DailyForecastDomain(
             forecast: <ForecastItemDomain>[],
           ),
           date: DateTime.now(),
         ),
       ) {
    on<FetchWeather>(_onFetchWeather);
    on<RefreshWeather>(_onRefreshWeather);
    on<ToggleUnits>(_onToggleUnits);
    on<GetOutfitEvent>(_onOutfitRecommendationRequested);
    on<FetchDailyForecast>(_onFetchDailyForecast);
    on<UpdateWeatherOnMobileHomeScreenEvent>(_updateWeatherOnMobileHomeScreen);
    on<CheckDateChangeOnResume>(_checkDateChangeOnResume);
    on<ToggleFavouriteEvent>(_onToggleFavourite);
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
    final bool isFavourite = _localDataSource.isFavouriteLocation(
      eventLocation,
    );

    // 1. Check for cached data to emit a "Stale" state immediately.
    final Map<String, dynamic>? cachedData = _localDataSource
        .getCachedWeatherBundle(eventLocation);

    if (cachedData != null) {
      try {
        final Weather cachedWeather = Weather.fromJson(
          cachedData['weather'] as Map<String, dynamic>,
        );
        final DailyForecastDomain cachedForecast = DailyForecastDomain.fromJson(
          cachedData['dailyForecast'] as Map<String, dynamic>,
        );
        final OutfitImage cachedOutfitImage = OutfitImage.fromJson(
          cachedData['outfitImage'] as Map<String, dynamic>,
        );
        final String cachedRecommendation =
            cachedData['outfitRecommendation'] as String;

        emit(
          WeatherSuccess(
            locale: savedLocale,
            weather: cachedWeather,
            dailyForecast: cachedForecast,
            outfitRecommendation: cachedRecommendation,
            outfitImage: cachedOutfitImage,
            date: state.date,
            isFavourite: isFavourite,
          ),
        );
      } catch (e) {
        debugPrint('Error loading cached weather bundle: $e');
      }
    }

    if (eventLocation.isEmpty) {
      emit(
        WeatherInitial(
          locale: savedLocale,
          dailyForecast: state.dailyForecast,
          date: DateTime.now(),
          isFavourite: isFavourite,
        ),
      );
    } else {
      // If we don't have cache, or even if we do, we show a localized loader
      // (or just revalidate in background).
      if (cachedData == null) {
        emit(
          WeatherLoadingState(
            locale: savedLocale,
            weather: state.weather,
            dailyForecast: state.dailyForecast,
            date: state.date,
            isFavourite: isFavourite,
          ),
        );
      }

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

        final OutfitImage outfitImage = await _outfitRepository.getOutfitImage(
          weather,
        );

        // 2. Persist the new "Weather Bundle" for future swipes.
        await _localDataSource.cacheWeatherBundle(
          location: eventLocation,
          weather: updatedWeather,
          dailyForecast: dailyForecast,
          outfitRecommendation: outfitRecommendation,
          outfitImage: outfitImage,
        );

        emit(
          WeatherSuccess(
            locale: savedLocale,
            weather: updatedWeather,
            outfitRecommendation: outfitRecommendation,
            outfitImage: outfitImage,
            dailyForecast: dailyForecast,
            date: state.date,
            isFavourite: isFavourite,
          ),
        );

        final WeatherFetchOrigin eventOrigin = event.origin;
        if (!kIsWeb && !Platform.isMacOS && eventOrigin.isNotWearable) {
          add(UpdateWeatherOnMobileHomeScreenEvent(eventOrigin));
        }
      } on Exception catch (exception) {
        debugPrint('WeatherBloc _onFetchWeather Exception: $exception.');
        if (cachedData == null) {
          final String stateOutfitRecommendation = state.outfitRecommendation;
          emit(
            WeatherFailure(
              locale: savedLocale,
              weather: state.weather,
              message: _mapExceptionToMessage(exception),
              outfitRecommendation: stateOutfitRecommendation,
              dailyForecast: state.dailyForecast,
              date: state.date,
              isFavourite: isFavourite,
            ),
          );
        }
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
    final bool isFavourite = _localDataSource.isFavouriteLocation(
      stateWeather.location,
    );
    final DateTime now = DateTime.now();
    if (state is WeatherSuccess || state is WeatherFailure) {
      if (state is WeatherFailure) {
        debugPrint('Failed to get weather on refresh: $state');
      }
      if (stateWeather.isNoLocation) {
        emit(
          WeatherInitial(
            locale: savedLocale,
            dailyForecast: state.dailyForecast,
            date: now,
            isFavourite: isFavourite,
          ),
        );
      } else {
        emit(
          WeatherLoadingState(
            locale: savedLocale,
            weather: stateWeather,
            outfitRecommendation: stateOutfitRecommendation,
            outfitImage: stateOutfitImage,
            dailyForecast: state.dailyForecast,
            date: now,
            isFavourite: isFavourite,
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

          final Weather updatedWeatherWithUnits = weather.copyWith(
            temperature: Temperature(value: temperatureValue),
            temperatureUnits: units,
          );

          // Update cache on refresh too.
          await _localDataSource.cacheWeatherBundle(
            location: stateLocation,
            weather: updatedWeatherWithUnits,
            dailyForecast: dailyForecast,
            outfitRecommendation: updatedOutfitRecommendation,
            outfitImage: updatedOutfitImage,
          );

          emit(
            WeatherSuccess(
              locale: savedLocale,
              weather: updatedWeatherWithUnits,
              outfitRecommendation: updatedOutfitRecommendation,
              outfitImage: updatedOutfitImage,
              dailyForecast: dailyForecast,
              date: now,
              isFavourite: isFavourite,
            ),
          );

          final WeatherFetchOrigin eventOrigin = event.origin;
          if (!kIsWeb && !Platform.isMacOS && eventOrigin.isNotWearable) {
            add(UpdateWeatherOnMobileHomeScreenEvent(eventOrigin));
          }
        } on Exception catch (e) {
          debugPrint('Failed to get weather: $e');
          emit(
            WeatherFailure(
              locale: savedLocale,
              weather: stateWeather,
              message: _mapExceptionToMessage(e),
              outfitRecommendation: stateOutfitRecommendation,
              outfitImage: stateOutfitImage,
              dailyForecast: state.dailyForecast,
              date: now,
              isFavourite: isFavourite,
            ),
          );
        }
      }
    } else {
      emit(
        WeatherInitial(
          locale: savedLocale,
          weather: stateWeather,
          outfitRecommendation: stateOutfitRecommendation,
          outfitImage: stateOutfitImage,
          dailyForecast: state.dailyForecast,
          date: state.date,
          isFavourite: isFavourite,
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

    final WeatherState currentState = state;

    if (currentState is WeatherSuccess) {
      final Weather updatedWeather = weather.copyWith(
        temperature: Temperature(value: value),
        temperatureUnits: units,
      );

      emit(currentState.copyWith(weather: updatedWeather));
    } else if (currentState is WeatherInitial) {
      emit(
        currentState.copyWith(
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
    final bool isFavourite = _localDataSource.isFavouriteLocation(
      eventLocation,
    );

    if (eventWeather.isEmpty) {
      emit(
        WeatherInitial(
          locale: savedLocale,
          dailyForecast: state.dailyForecast,
          date: state.date,
          isFavourite: isFavourite,
        ),
      );
    } else {
      final Weather localizedWeather = eventWeather.copyWith(
        location: eventLocation.copyWith(locale: savedLocale),
        locale: savedLocale,
      );
      emit(
        WeatherLoadingState(
          locale: savedLocale,
          weather: localizedWeather,
          dailyForecast: state.dailyForecast,
          date: state.date,
          isFavourite: isFavourite,
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
            date: state.date,
            isFavourite: isFavourite,
          ),
        );

        final WeatherState currentState = state;

        if (currentState is WeatherSuccess) {
          final OutfitImage outfitImage = await _outfitRepository
              .getOutfitImage(eventWeather);
          emit(currentState.copyWith(outfitImage: outfitImage));
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
          final OutfitImage outfitImage = await _outfitRepository
              .getOutfitImage(eventWeather);
          emit(
            WeatherSuccess(
              locale: savedLocale,
              weather: updatedWeather,
              outfitRecommendation: outfitRecommendation,
              outfitImage: outfitImage,
              dailyForecast: state.dailyForecast,
              date: state.date,
              isFavourite: isFavourite,
            ),
          );
        }
      } on Exception catch (e) {
        debugPrint(
          'WeatherBloc _onOutfitRecommendationRequested Exception: $e',
        );
        final String stateOutfitRecommendation = state.outfitRecommendation;
        if (e is http.ClientException && kDebugMode && kIsWeb) {
          emit(
            LocalWebCorsFailure(
              locale: savedLocale,
              weather: state.weather,
              message: translate('error.cors'),
              outfitRecommendation: stateOutfitRecommendation,
              dailyForecast: state.dailyForecast,
              date: state.date,
              isFavourite: isFavourite,
            ),
          );
        } else {
          emit(
            WeatherFailure(
              locale: savedLocale,
              weather: state.weather,
              message: _mapExceptionToMessage(e),
              outfitRecommendation: stateOutfitRecommendation,
              dailyForecast: state.dailyForecast,
              date: state.date,
              isFavourite: isFavourite,
            ),
          );
        }
      }
    }
  }

  FutureOr<void> _onFetchDailyForecast(
    FetchDailyForecast event,
    Emitter<WeatherState> emit,
  ) async {
    final String savedLocale = _localDataSource.getLanguageIsoCode();
    final bool isFavourite = _localDataSource.isFavouriteLocation(
      event.location,
    );
    emit(
      WeatherLoadingState(
        locale: savedLocale,
        weather: state.weather,
        dailyForecast: state.dailyForecast,
        outfitRecommendation: state.outfitRecommendation,
        outfitImage: state.outfitImage,
        date: state.date,
        isFavourite: isFavourite,
      ),
    );
    try {
      final DailyForecastDomain dailyForecast = await _weatherRepository
          .getDailyForecast(event.location);
      final WeatherState currentState = state;
      if (currentState is WeatherSuccess) {
        emit(currentState.copyWith(dailyForecast: dailyForecast));
      } else {
        emit(
          WeatherSuccess(
            locale: savedLocale,
            weather: state.weather,
            dailyForecast: dailyForecast,
            date: state.date,
            isFavourite: isFavourite,
          ),
        );
      }
    } on Exception catch (e) {
      debugPrint('Failed to get daily forecast: $e');
      emit(
        WeatherFailure(
          locale: savedLocale,
          weather: state.weather,
          message: _mapExceptionToMessage(e),
          outfitRecommendation: state.outfitRecommendation,
          outfitImage: state.outfitImage,
          dailyForecast: state.dailyForecast,
          date: state.date,
          isFavourite: isFavourite,
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

        // Ensure native widget receives current locale for localization.
        try {
          final String languageCode = _localDataSource.getLanguageIsoCode();
          // Use the service instead of calling HomeWidget directly.
          await _homeWidgetService.saveWidgetData<String>(
            'selected_language',
            languageCode,
          );
        } catch (e) {
          debugPrint('Failed to save widget language: $e');
        }

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

  /// Maps an [Exception] to a localized user-friendly message.
  String _mapExceptionToMessage(Object e) {
    final String errorString = e.toString();
    if (e is SocketException ||
        errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup') ||
        errorString.contains('HandshakeException') ||
        errorString.contains('Connection refused') ||
        errorString.contains('Connection closed')) {
      return translate('error.network_error');
    }
    if (e is WeatherRequestFailure) {
      return translate('error.getting_weather_bloc_generic');
    }
    return translate('error.something_went_wrong');
  }

  void _checkDateChangeOnResume(
    CheckDateChangeOnResume event,
    Emitter<WeatherState> emit,
  ) {
    final DateTime now = DateTime.now();
    final DateTime lastDataDate = state.date;

    // If the date has changed since the app was last active, reload entries
    if (!lastDataDate.isSameDate(now)) {
      add(RefreshWeather(event.origin));
    }
  }

  FutureOr<void> _onToggleFavourite(
    ToggleFavouriteEvent event,
    Emitter<WeatherState> emit,
  ) async {
    final Location location = event.location;
    final bool currentlyFavourite = _localDataSource.isFavouriteLocation(
      location,
    );
    if (currentlyFavourite) {
      await _localDataSource.removeFavouriteLocation(location);
    } else {
      await _localDataSource.saveFavouriteLocation(location);
    }

    final WeatherState currentState = state;
    if (currentState is WeatherSuccess) {
      emit(currentState.copyWith(isFavourite: !currentlyFavourite));
    } else if (currentState is WeatherInitial) {
      emit(currentState.copyWith(isFavourite: !currentlyFavourite));
    } else if (currentState is WeatherFailure) {
      emit(currentState.copyWith(isFavourite: !currentlyFavourite));
    } else if (currentState is LocalWebCorsFailure) {
      emit(currentState.copyWith(isFavourite: !currentlyFavourite));
    } else {
      emit(currentState);
    }
  }
}
