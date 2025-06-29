import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(
    this._weatherRepository,
    this._locationRepository,
    this._localDataSource,
  ) : super(const SearchInitial()) {
    on<SearchLocation>(_searchLocation);
    on<ConfirmLocation>(_confirmLocation);
    on<SearchByLocation>(_searchByLocation);
    on<RequestPermissionAndSearchByLocation>(_onRequestLocationPermission);
  }

  final WeatherRepository _weatherRepository;
  final LocationRepository _locationRepository;
  final LocalDataSource _localDataSource;

  FutureOr<void> _searchByLocation(
    SearchByLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());
    try {
      final WeatherDomain weather =
          await _weatherRepository.getWeatherByLocation(
        Location(
          latitude: event.latitude,
          longitude: event.longitude,
          locale: _localDataSource.getLanguageIsoCode(),
        ),
      );
      emit(SearchWeatherLoaded(Weather.fromRepository(weather)));
    } catch (e, stackTrace) {
      // 1. Log the detailed error with function name for debugging.
      final String debugErrorMessage =
          '[_searchByLocation] Error getting weather: $e';
      debugPrint('$debugErrorMessage\n$stackTrace');

      // 2. Determine the user-facing error message
      final String userFriendlyErrorMessage = translate(
        'error.getting_weather_generic',
      );

      emit(SearchError(userFriendlyErrorMessage));
    }
  }

  FutureOr<void> _confirmLocation(
    ConfirmLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());
    try {
      final WeatherDomain weather =
          await _weatherRepository.getWeatherByLocation(
        event.location,
      );
      emit(SearchWeatherLoaded(Weather.fromRepository(weather)));
    } catch (e, stackTrace) {
      // 1. Log the detailed error with function name for debugging.
      final String debugErrorMessage =
          '[_confirmLocation] Error getting weather: $e';
      debugPrint('$debugErrorMessage\n$stackTrace');

      // 2. Determine the user-facing error message.
      final String userFriendlyErrorMessage = translate(
        'error.getting_weather_generic',
      );

      emit(SearchError(userFriendlyErrorMessage));
    }
  }

  Future<void> _onRequestLocationPermission(
    RequestPermissionAndSearchByLocation _,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());

    try {
      await _requestLocationPermission();

      final Position position = await Geolocator.getCurrentPosition();

      final WeatherDomain weather =
          await _weatherRepository.getWeatherByLocation(
        Location(
          latitude: position.latitude,
          longitude: position.longitude,
          locale: _localDataSource.getLanguageIsoCode(),
        ),
      );

      emit(SearchWeatherLoaded(Weather.fromRepository(weather)));
    } catch (e, stackTrace) {
      // 1. Log the detailed error with function name for debugging
      final String debugErrorMessage =
          '[_onRequestLocationPermission] Error getting weather: $e';
      debugPrint('error: $debugErrorMessage\n$stackTrace');

      // 2. Determine the user-facing error message.
      String userFriendlyErrorMessage;
      if (e.toString().contains(
            translate(
              // Check if the error is one of our translated permission errors.
              'error.location_permission_permanently_denied_cannot_request',
            ),
          )) {
        userFriendlyErrorMessage = translate(
          'error.location_permission_permanently_denied_cannot_request',
        );
      } else if (e.toString().contains(
            translate('error.location_permission_denied'),
          )) {
        userFriendlyErrorMessage = translate(
          'error.location_permission_denied',
        );
      } else {
        // Generic error message for other cases.
        userFriendlyErrorMessage = translate('error.getting_weather_generic');
      }
      emit(SearchError(userFriendlyErrorMessage));
    }
  }

  FutureOr<void> _searchLocation(
    SearchLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());

    try {
      final Location location = await _locationRepository.getLocation(
        event.query,
      );

      emit(SearchLocationFound(location));
    } catch (e) {
      emit(SearchError('${translate('error.searching_location')}: $e'));
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now).
        return Future<void>.error(
          translate('error.location_permission_denied'),
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future<void>.error(
        translate(
          'error.location_permission_permanently_denied_cannot_request',
        ),
      );
    }
  }
}
