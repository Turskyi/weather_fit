import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
import 'package:weather_fit/extensions/build_context_extensions.dart';
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
           weather: Weather.empty.copyWith(
             temperatureUnits: localDataSource.getTemperatureUnits(),
           ),
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
    on<UpdateWeatherOnHomeWidgetEvent>(_updateWeatherOnHomeWidget);
    on<CheckHourChangeOnResume>(_checkHourChangeOnResume);
    on<ToggleFavouriteEvent>(_onToggleFavourite);

    _scheduleInitialHomeWidgetSync();
  }

  final WeatherRepository _weatherRepository;
  final OutfitRepository _outfitRepository;
  final LocalDataSource _localDataSource;
  final HomeWidgetService _homeWidgetService;

  void _scheduleInitialHomeWidgetSync() {
    if (kIsWeb || isWearDevice) {
      return;
    }

    final DailyForecastDomain? dailyForecast = state.dailyForecast;
    if (dailyForecast == null || dailyForecast.forecast.isEmpty) {
      return;
    }

    if (state.weather.isEmpty) {
      return;
    }

    Future<void>.microtask(() {
      add(
        const UpdateWeatherOnHomeWidgetEvent(WeatherFetchOrigin.defaultDevice),
      );
    });
  }

  @override
  WeatherState? fromJson(Map<String, Object?> json) {
    try {
      if (json.isEmpty) return null;
      // Since we primarily care about restoring successful weather data,
      // we try to restore as WeatherSuccess.
      return WeatherSuccess.fromJson(json);
    } catch (e) {
      debugPrint('WeatherBloc fromJson error: $e');
      return null;
    }
  }

  @override
  Map<String, Object?> toJson(WeatherState state) {
    if (state is WeatherSuccess ||
        state is WeatherFailure ||
        state is WeatherInitial) {
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
    final Location selectedLocation = _localDataSource.getLastSavedLocation();
    final bool isSelectedAtStart = _isSelectedLocation(eventLocation);
    debugPrint(
      'WeatherBloc fetch: start '
      '(eventLocation=$eventLocation, selectedLocation=$selectedLocation, '
      'isSelected=$isSelectedAtStart).',
    );

    if (isSelectedAtStart) {
      final String savedLocale = _localDataSource.getLanguageIsoCode();
      final bool isFavourite = _localDataSource.isFavouriteLocation(
        eventLocation,
      );

      // 1. Check for cached data to emit a "Stale" state immediately.
      final Map<String, dynamic>? cachedData = _localDataSource
          .getCachedWeatherBundle(eventLocation);

      debugPrint(
        'WeatherBloc fetch: cache lookup '
        '(eventLocation=$eventLocation, hasCache=${cachedData != null}).',
      );

      if (cachedData != null && _isSelectedLocation(eventLocation)) {
        try {
          final Weather cachedWeather = Weather.fromJson(
            cachedData['weather'] as Map<String, dynamic>,
          );

          final TemperatureUnits units = state.temperatureUnits;
          final Weather updatedCachedWeather;

          if (cachedWeather.temperatureUnits != units) {
            final double value = units.isFahrenheit
                ? cachedWeather.temperature.value.toFahrenheit()
                : cachedWeather.temperature.value.toCelsius();

            updatedCachedWeather = cachedWeather.copyWith(
              temperature: Temperature(value: value),
              temperatureUnits: units,
            );
          } else {
            updatedCachedWeather = cachedWeather;
          }

          final DailyForecastDomain cachedForecast =
              DailyForecastDomain.fromJson(
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
              weather: updatedCachedWeather,
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
          debugPrint(
            'WeatherBloc fetch: emit WeatherLoadingState '
            '(eventLocation=$eventLocation).',
          );
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

          final bool isSelectedAfterForecast = _isSelectedLocation(
            eventLocation,
          );
          if (isSelectedAfterForecast) {
            final WeatherDomain domainWeather = await _getWeatherByLocation(
              eventLocation,
            );

            final bool isSelectedAfterWeather = _isSelectedLocation(
              eventLocation,
            );
            if (isSelectedAfterWeather) {
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

              final OutfitImage outfitImage = await _outfitRepository
                  .getOutfitImage(weather);

              // 2. Persist the new "Weather Bundle" for future swipes.
              await _localDataSource.cacheWeatherBundle(
                location: eventLocation,
                weather: updatedWeather,
                dailyForecast: dailyForecast,
                outfitRecommendation: outfitRecommendation,
                outfitImage: outfitImage,
              );

              if (_isSelectedLocation(eventLocation)) {
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
                if (!kIsWeb && eventOrigin.isNotWearable) {
                  add(UpdateWeatherOnHomeWidgetEvent(eventOrigin));
                }
              } else {
                debugPrint(
                  'WeatherBloc fetch: skip emit WeatherSuccess '
                  '(eventLocation=$eventLocation, reason=not_selected_final).',
                );
              }
            } else {
              debugPrint(
                'WeatherBloc fetch: skip weather mapping '
                '(eventLocation=$eventLocation, '
                'reason=not_selected_after_weather).',
              );
            }
          } else {
            debugPrint(
              'WeatherBloc fetch: skip weather request '
              '(eventLocation=$eventLocation, '
              'reason=not_selected_after_forecast).',
            );
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
    } else {
      debugPrint(
        'WeatherBloc fetch: ignore event '
        '(eventLocation=$eventLocation, selectedLocation=$selectedLocation).',
      );
    }
  }

  bool _isSelectedLocation(Location location) {
    final Location selectedLocation = _localDataSource.getLastSavedLocation();

    if (selectedLocation.isEmpty) {
      return true;
    } else {
      return selectedLocation.isSamePlaceAs(location);
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

    // Determine which location to refresh.
    // If the current state has no location, fallback to the last saved
    // location.
    Location locationToRefresh = stateWeather.location;
    if (locationToRefresh.isEmpty) {
      locationToRefresh = _localDataSource.getLastSavedLocation();
    }

    if (locationToRefresh.isEmpty) {
      // If we still have no location, we emit WeatherInitial as expected by
      // tests.
      emit(
        WeatherInitial(
          locale: savedLocale,
          dailyForecast: state.dailyForecast,
          date: state.date,
          isFavourite: state.isFavourite,
        ),
      );
      return;
    }

    final bool isFavourite = _localDataSource.isFavouriteLocation(
      locationToRefresh,
    );
    final DateTime now = DateTime.now();

    if (state is WeatherSuccess || state is WeatherFailure) {
      await _refreshWeatherAndCache(
        stateWeather: stateWeather.isNotEmpty
            ? stateWeather
            : Weather.empty.copyWith(
                location: locationToRefresh,
                temperatureUnits: state.temperatureUnits,
              ),
        emit: emit,
        savedLocale: savedLocale,
        now: now,
        isFavourite: isFavourite,
        stateOutfitRecommendation: stateOutfitRecommendation,
        stateOutfitImage: stateOutfitImage,
        event: event,
      );
    } else {
      emit(
        WeatherInitial(
          locale: savedLocale,
          weather: stateWeather.isNotEmpty
              ? stateWeather
              : Weather.empty.copyWith(
                  location: locationToRefresh,
                  temperatureUnits: state.temperatureUnits,
                ),
          outfitRecommendation: stateOutfitRecommendation,
          outfitImage: stateOutfitImage,
          dailyForecast: state.dailyForecast,
          date: state.date,
          isFavourite: isFavourite,
        ),
      );
      add(FetchWeather(location: locationToRefresh, origin: event.origin));
    }
  }

  Future<void> _refreshWeatherAndCache({
    required Weather stateWeather,
    required Emitter<WeatherState> emit,
    required String savedLocale,
    required DateTime now,
    required bool isFavourite,
    required String stateOutfitRecommendation,
    required OutfitImage stateOutfitImage,
    required RefreshWeather event,
  }) async {
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
        final Location stateLocation = stateWeather.location;
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
        if (!kIsWeb && eventOrigin.isNotWearable) {
          add(UpdateWeatherOnHomeWidgetEvent(eventOrigin));
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
  }

  Future<WeatherDomain> _getWeatherByLocation(Location location) {
    return _weatherRepository.getWeatherByLocation(location);
  }

  String _getOutfitRecommendation(Weather weather) {
    return _outfitRepository.getOutfitRecommendation(weather);
  }

  String _mapExceptionToMessage(Exception exception) {
    if (exception is http.ClientException || exception is SocketException) {
      return translate('errors.no_internet');
    }
    return translate('errors.unknown');
  }

  FutureOr<void> _onToggleUnits(
    ToggleUnits event,
    Emitter<WeatherState> emit,
  ) async {
    final Weather stateWeather = state.weather;
    final TemperatureUnits units = stateWeather.temperatureUnits.isCelsius
        ? TemperatureUnits.fahrenheit
        : TemperatureUnits.celsius;

    await _localDataSource.saveTemperatureUnits(units);

    final double value = units.isFahrenheit
        ? stateWeather.temperature.value.toFahrenheit()
        : stateWeather.temperature.value.toCelsius();

    final Weather updatedWeather = stateWeather.copyWith(
      temperature: Temperature(value: value),
      temperatureUnits: units,
    );

    if (state is WeatherSuccess) {
      emit(
        (state as WeatherSuccess).copyWith(
          weather: updatedWeather,
          date: state.date,
        ),
      );
    } else if (state is WeatherFailure) {
      emit(
        (state as WeatherFailure).copyWith(
          weather: updatedWeather,
          date: state.date,
        ),
      );
    } else if (state is WeatherLoadingState) {
      emit(
        (state as WeatherLoadingState).copyWith(
          weather: updatedWeather,
          date: state.date,
        ),
      );
    } else if (state is WeatherInitial) {
      emit(
        (state as WeatherInitial).copyWith(
          weather: updatedWeather,
          date: state.date,
        ),
      );
    }
  }

  FutureOr<void> _onOutfitRecommendationRequested(
    GetOutfitEvent event,
    Emitter<WeatherState> emit,
  ) async {
    final Weather eventWeather = event.weather;
    if (eventWeather.isNoLocation) return;

    final String savedLocale = _localDataSource.getLanguageIsoCode();
    final bool isFavourite = _localDataSource.isFavouriteLocation(
      eventWeather.location,
    );

    emit(
      LoadingOutfitState(
        locale: savedLocale,
        weather: eventWeather,
        dailyForecast: state.dailyForecast,
        date: state.date,
        isFavourite: isFavourite,
      ),
    );

    try {
      final String outfitRecommendation = _outfitRepository
          .getOutfitRecommendation(eventWeather);

      final OutfitImage outfitImage = await _outfitRepository.getOutfitImage(
        eventWeather,
      );

      emit(
        WeatherSuccess(
          locale: savedLocale,
          weather: eventWeather,
          outfitRecommendation: outfitRecommendation,
          outfitImage: outfitImage,
          dailyForecast: state.dailyForecast,
          date: state.date,
          isFavourite: isFavourite,
        ),
      );
    } on Exception catch (exception) {
      debugPrint(
        'WeatherBloc _onOutfitRecommendationRequested Exception: $exception.',
      );
      emit(
        WeatherFailure(
          locale: savedLocale,
          weather: eventWeather,
          message: _mapExceptionToMessage(exception),
          dailyForecast: state.dailyForecast,
          date: state.date,
          isFavourite: isFavourite,
        ),
      );
    }
  }

  FutureOr<void> _onFetchDailyForecast(
    FetchDailyForecast event,
    Emitter<WeatherState> emit,
  ) async {
    final Location eventLocation = event.location;
    final String savedLocale = _localDataSource.getLanguageIsoCode();
    final bool isFavourite = _localDataSource.isFavouriteLocation(
      eventLocation,
    );

    try {
      final DailyForecastDomain dailyForecast = await _weatherRepository
          .getDailyForecast(eventLocation);

      if (state is WeatherSuccess) {
        emit(
          (state as WeatherSuccess).copyWith(
            dailyForecast: dailyForecast,
            date: state.date,
          ),
        );
      } else if (state is WeatherInitial) {
        emit(
          (state as WeatherInitial).copyWith(
            dailyForecast: dailyForecast,
            date: state.date,
          ),
        );
      } else if (state is WeatherFailure) {
        emit(
          (state as WeatherFailure).copyWith(
            dailyForecast: dailyForecast,
            date: state.date,
          ),
        );
      }
    } on Exception catch (exception) {
      debugPrint('WeatherBloc _onFetchDailyForecast Exception: $exception.');
      emit(
        WeatherFailure(
          locale: savedLocale,
          weather: state.weather,
          message: _mapExceptionToMessage(exception),
          dailyForecast: state.dailyForecast,
          date: state.date,
          isFavourite: isFavourite,
        ),
      );
    }
  }

  FutureOr<void> _updateWeatherOnHomeWidget(
    UpdateWeatherOnHomeWidgetEvent event,
    Emitter<WeatherState> emit,
  ) async {
    final DailyForecastDomain? dailyForecast = state.dailyForecast;
    if (dailyForecast != null) {
      debugPrint(
        'WeatherBloc widget update: start '
        '(origin=${event.origin}, state=${state.runtimeType}, '
        'location=${state.weather.location}).',
      );
      try {
        await _homeWidgetService.updateHomeWidget(
          localDataSource: _localDataSource,
          weather: state.weather,
          forecast: dailyForecast,
          outfitRepository: _outfitRepository,
        );
        debugPrint('WeatherBloc widget update: completed.');
      } on PlatformException catch (e) {
        debugPrint('Home widget update skipped: $e');
      }
    } else {
      debugPrint(
        'WeatherBloc widget update: skipped because forecast is null '
        '(origin=${event.origin}).',
      );
    }
  }

  FutureOr<void> _checkHourChangeOnResume(
    CheckHourChangeOnResume event,
    Emitter<WeatherState> emit,
  ) {
    final DateTime now = DateTime.now();
    if (state.date.isSameHour(now)) {
      debugPrint(
        'WeatherBloc resume check: skip refresh '
        '(stateDate=${state.date.toIso8601String()}, '
        'now=${now.toIso8601String()}).',
      );
    } else {
      debugPrint(
        'WeatherBloc resume check: refresh weather '
        '(stateDate=${state.date.toIso8601String()}, '
        'now=${now.toIso8601String()}).',
      );
      add(RefreshWeather(event.origin));
    }
  }

  FutureOr<void> _onToggleFavourite(
    ToggleFavouriteEvent event,
    Emitter<WeatherState> emit,
  ) async {
    final Location location = event.location;
    final bool isFavourite = _localDataSource.isFavouriteLocation(location);

    if (isFavourite) {
      await _localDataSource.removeFavouriteLocation(location);
    } else {
      await _localDataSource.saveFavouriteLocation(location);
    }

    final bool updatedIsFavourite = !isFavourite;

    if (state is WeatherSuccess) {
      emit((state as WeatherSuccess).copyWith(isFavourite: updatedIsFavourite));
    } else if (state is WeatherFailure) {
      emit((state as WeatherFailure).copyWith(isFavourite: updatedIsFavourite));
    } else if (state is WeatherInitial) {
      emit((state as WeatherInitial).copyWith(isFavourite: updatedIsFavourite));
    } else if (state is WeatherLoadingState) {
      emit(
        (state as WeatherLoadingState).copyWith(
          isFavourite: updatedIsFavourite,
        ),
      );
    }
  }
}
