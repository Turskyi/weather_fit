import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/entities/enums/search_error_type.dart';
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
      final WeatherDomain weather = await _weatherRepository
          .getWeatherByLocation(
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

      // 2. Determine the user-facing error message.
      final String userFriendlyErrorMessage = translate(
        'error.getting_weather_generic',
      );

      emit(
        SearchError(
          errorMessage: userFriendlyErrorMessage,
          errorType: SearchErrorType.unknown,
          query: '${event.latitude}, ${event.longitude}',
        ),
      );
    }
  }

  FutureOr<void> _confirmLocation(
    ConfirmLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());
    try {
      final WeatherDomain weather = await _weatherRepository
          .getWeatherByLocation(event.location);
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

      emit(
        SearchError(
          errorMessage: userFriendlyErrorMessage,
          query: '${event.location}',
          errorType: SearchErrorType.unknown,
        ),
      );
    }
  }

  Future<void> _onRequestLocationPermission(
    RequestPermissionAndSearchByLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());

    try {
      await _requestLocationPermission();

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      final Position position = await Geolocator.getCurrentPosition();
      final String languageIsoCode = _localDataSource.getLanguageIsoCode();

      final WeatherDomain domainWeather = await _weatherRepository
          .getWeatherByLocation(
            Location(
              latitude: position.latitude,
              longitude: position.longitude,
              locale: languageIsoCode,
            ),
          );
      final Weather weather = Weather.fromRepository(domainWeather);
      emit(SearchWeatherLoaded(weather));
    } catch (e, stackTrace) {
      // 1. Log the detailed error with function name for debugging
      final String debugErrorMessage =
          '[_onRequestLocationPermission] Error getting weather: $e';
      debugPrint('error: $debugErrorMessage\n$stackTrace');

      // 2. Determine the user-facing error message.
      String userFriendlyErrorMessage = translate(
        'error.getting_weather_generic',
      );
      SearchErrorType searchErrorType = SearchErrorType.unknown;

      if (e is LocationServiceDisabledException) {
        // TODO: implement displaying a full screen dialog where we would
        //  explain, that if we get here and location permission is enabled
        //  means app cannot find the location and we are very sorry. Suggest
        //  to "type" another city, or country or report the error to developer
        //  or uninstall the app.
        userFriendlyErrorMessage = translate('error.location_unavailable');
        searchErrorType = SearchErrorType.locationServiceDisabled;
      } else if (e.toString().contains(
        translate(
          // Check if the error is one of our translated permission errors.
          'error.location_permission_permanently_denied_cannot_request',
        ),
      )) {
        userFriendlyErrorMessage = translate(
          'error.location_permission_permanently_denied_cannot_request',
        );
        searchErrorType = SearchErrorType.permissionDeniedPermanently;
      } else if (e.toString().contains(
        translate('error.location_permission_denied'),
      )) {
        userFriendlyErrorMessage = translate(
          'error.location_permission_denied',
        );
        searchErrorType = SearchErrorType.permissionDenied;
      }

      emit(
        SearchError(
          errorMessage: userFriendlyErrorMessage,
          errorType: searchErrorType,
          query: event.query,
        ),
      );
    }
  }

  FutureOr<void> _searchLocation(
    SearchLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());

    // It is important to `trim` the query before passing it to the repository,
    // otherwise query with trailing spaces will return wrong location.
    final String eventQuery = event.query.trim();

    if (eventQuery.isEmpty) {
      //TODO: For some reason the query is empty. This should not have
      // happened. Maybe inform user that he has to type something "
      emit(const SearchInitial());
    } else {
      try {
        final Location location = await _locationRepository.getLocation(
          eventQuery,
        );

        emit(SearchLocationFound(location));
      } catch (e, stackTrace) {
        // The logging of this error in in the end of this block.
        String userFriendlyMessage = translate('error.searching_location');
        SearchErrorType errorType = SearchErrorType.unknown;
        final String detailedMessage = e.toString();

        if (e is HandshakeException &&
            detailedMessage.contains('CERTIFICATE_VERIFY_FAILED')) {
          userFriendlyMessage = translate(
            'error.certificate_validation_failed_user_message',
          );
          errorType = SearchErrorType.certificateValidationFailed;
        } else if (e is SocketException) {
          debugPrint(
            '[_searchLocation] SocketException: $e\nquery: $eventQuery\n'
            '$stackTrace.',
          );

          userFriendlyMessage = translate('error.network_error');
          errorType = SearchErrorType.network;
          emit(
            SearchError(
              errorMessage: userFriendlyMessage,
              errorType: errorType,
              query: eventQuery,
            ),
          );
        } else if (e is LocationNotFoundFailure) {
          emit(SearchLocationNotFound(eventQuery));
        } else {
          emit(
            SearchError(
              errorMessage: userFriendlyMessage,
              errorType: errorType,
              query: eventQuery,
            ),
          );
        }
        debugPrint('[_searchLocation] Error: $detailedMessage\n$stackTrace');
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      // Test if location services are enabled.
      final bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!isServiceEnabled) {
        // TODO: implement another dialog to inform user that we will open
        //  system location settings with a call
        //  `await Geolocator.openLocationSettings();`

        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        return Future<void>.error('Location services are disabled.');
      }
    } catch (e) {
      if (e.toString().contains('LOCATION_SERVICES_DISABLED')) {
        // TODO: implement another dialog to inform user that we will open
        //  system location settings with a call
        //  `await Geolocator.openLocationSettings();`
        return Future<void>.error('Location services are disabled.');
      }
    }
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
    // We expect here `LocationPermission.whileInUse`.
    debugPrint('Location permission granted with value: $permission.');
  }
}
