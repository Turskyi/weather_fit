import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as geo;
import 'package:nominatim_api/nominatim_api.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/entities/enums/search_error_type.dart';
import 'package:weather_fit/entities/models/quick_city_suggestion.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required WeatherRepository weatherRepository,
    required LocationRepository locationRepository,
    required LocalDataSource localDataSource,
  }) : _weatherRepository = weatherRepository,
       _locationRepository = locationRepository,
       _localDataSource = localDataSource,
       super(
         SearchInitial(
           quickCitiesSuggestions: <QuickCitySuggestion>[
             QuickCitySuggestion(
               name: translate(
                 localDataSource.getSavedLanguage().isUkrainian
                     ? 'search.quick_city_north_york'
                     : 'search.quick_city_toronto',
               ),
               flag: '🇨🇦',
             ),
             QuickCitySuggestion(
               name: translate('search.quick_city_zielona_gora'),
               flag: '🇵🇱',
             ),
             QuickCitySuggestion(
               name: translate('search.quick_city_zaporizhzhia'),
               flag: '🇺🇦',
             ),
             QuickCitySuggestion(
               name: translate('search.quick_city_waldshut_tiengen'),
               flag: '🇩🇪',
             ),
           ],
         ),
       ) {
    on<SearchLocation>(_searchLocation);
    on<ConfirmLocation>(_confirmLocation);
    on<SearchByLocation>(_searchByLocation);
    on<RequestPermissionAndSearchByLocation>(_onRequestLocationPermission);
    on<RetrySearchByCurrentLocation>(_onRetrySearchByCurrentLocation);
  }

  final WeatherRepository _weatherRepository;
  final LocationRepository _locationRepository;
  final LocalDataSource _localDataSource;

  List<QuickCitySuggestion> get _quickCitiesSuggestions =>
      state.quickCitiesSuggestions;

  Future<void> _onRetrySearchByCurrentLocation(
    RetrySearchByCurrentLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(quickCitiesSuggestions: _quickCitiesSuggestions));

    try {
      await _requestLocationPermission();

      final Position position = await _getCurrentPosition();
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
      emit(
        SearchWeatherLoaded(
          weather: weather,
          quickCitiesSuggestions: _quickCitiesSuggestions,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[_onRetrySearchByCurrentLocation] '
        'Error type: ${e.runtimeType}\n'
        'Error: $e\n'
        'Stack trace: $stackTrace',
      );

      String userFriendlyErrorMessage = translate(
        'error.getting_weather_retry_request_permission',
      );
      SearchErrorType searchErrorType = SearchErrorType.unknown;

      final String detailedMessage = e.toString();
      if (e is HandshakeException &&
          detailedMessage.contains('CERTIFICATE_VERIFY_FAILED')) {
        userFriendlyErrorMessage = translate(
          'error.certificate_validation_failed_user_message',
        );
        searchErrorType = SearchErrorType.certificateValidationFailed;
      } else if (e is SocketException) {
        userFriendlyErrorMessage = translate('error.network_error');
        searchErrorType = SearchErrorType.network;
      } else if (e is LocationServiceDisabledException) {
        userFriendlyErrorMessage = translate('error.location_unavailable');
        searchErrorType = SearchErrorType.locationServiceDisabled;
      } else if (e.toString().contains(
        translate(
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
          quickCitiesSuggestions: _quickCitiesSuggestions,
        ),
      );
    }
  }

  FutureOr<void> _searchByLocation(
    SearchByLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(quickCitiesSuggestions: _quickCitiesSuggestions));
    try {
      final WeatherDomain weather = await _weatherRepository
          .getWeatherByLocation(
            Location(
              latitude: event.latitude,
              longitude: event.longitude,
              locale: _localDataSource.getLanguageIsoCode(),
            ),
          );
      emit(
        SearchWeatherLoaded(
          weather: Weather.fromRepository(weather),
          quickCitiesSuggestions: _quickCitiesSuggestions,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[_searchByLocation] '
        'Error type: ${e.runtimeType}\n'
        'Error: $e\n'
        'Stack trace: $stackTrace',
      );

      // 2. Determine the user-facing error message.
      String userFriendlyErrorMessage = translate(
        'error.getting_weather_search_by_location',
      );
      SearchErrorType searchErrorType = SearchErrorType.unknown;

      final String detailedMessage = e.toString();
      if (e is HandshakeException &&
          detailedMessage.contains('CERTIFICATE_VERIFY_FAILED')) {
        userFriendlyErrorMessage = translate(
          'error.certificate_validation_failed_user_message',
        );
        searchErrorType = SearchErrorType.certificateValidationFailed;
      } else if (e is SocketException) {
        userFriendlyErrorMessage = translate('error.network_error');
        searchErrorType = SearchErrorType.network;
      }

      emit(
        SearchError(
          errorMessage: userFriendlyErrorMessage,
          errorType: searchErrorType,
          query: '${event.latitude}, ${event.longitude}',
          quickCitiesSuggestions: _quickCitiesSuggestions,
        ),
      );
    }
  }

  FutureOr<void> _confirmLocation(
    ConfirmLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(quickCitiesSuggestions: _quickCitiesSuggestions));
    try {
      final WeatherDomain weather = await _weatherRepository
          .getWeatherByLocation(event.location);
      emit(
        SearchWeatherLoaded(
          weather: Weather.fromRepository(weather),
          quickCitiesSuggestions: _quickCitiesSuggestions,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[_confirmLocation] '
        'Error type: ${e.runtimeType}\n'
        'Error: $e\n'
        'Stack trace: $stackTrace',
      );

      // 2. Determine the user-facing error message.
      String userFriendlyErrorMessage = translate(
        'error.getting_weather_confirm_location',
      );
      SearchErrorType searchErrorType = SearchErrorType.unknown;

      final String detailedMessage = e.toString();
      if (e is HandshakeException &&
          detailedMessage.contains('CERTIFICATE_VERIFY_FAILED')) {
        userFriendlyErrorMessage = translate(
          'error.certificate_validation_failed_user_message',
        );
        searchErrorType = SearchErrorType.certificateValidationFailed;
      } else if (e is SocketException) {
        userFriendlyErrorMessage = translate('error.network_error');
        searchErrorType = SearchErrorType.network;
      }

      emit(
        SearchError(
          errorMessage: userFriendlyErrorMessage,
          query: '${event.location}',
          errorType: searchErrorType,
          quickCitiesSuggestions: _quickCitiesSuggestions,
        ),
      );
    }
  }

  Future<void> _onRequestLocationPermission(
    RequestPermissionAndSearchByLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(quickCitiesSuggestions: _quickCitiesSuggestions));

    try {
      await _requestLocationPermission();

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      final Position position = await _getCurrentPosition();
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
      emit(
        SearchWeatherLoaded(
          weather: weather,
          quickCitiesSuggestions: _quickCitiesSuggestions,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[_onRequestLocationPermission] '
        'Error type: ${e.runtimeType}\n'
        'Error: $e\n'
        'Stack trace: $stackTrace',
      );

      // 2. Determine the user-facing error message.
      String userFriendlyErrorMessage = translate(
        'error.getting_weather_request_permission',
      );

      SearchErrorType searchErrorType = SearchErrorType.unknown;

      final String detailedMessage = e.toString();
      if (e is HandshakeException &&
          detailedMessage.contains('CERTIFICATE_VERIFY_FAILED')) {
        userFriendlyErrorMessage = translate(
          'error.certificate_validation_failed_user_message',
        );
        searchErrorType = SearchErrorType.certificateValidationFailed;
      } else if (e is SocketException) {
        userFriendlyErrorMessage = translate('error.network_error');
        searchErrorType = SearchErrorType.network;
      } else if (e is LocationServiceDisabledException) {
        userFriendlyErrorMessage = translate(
          'error.location_services_disabled_content',
        );
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
          quickCitiesSuggestions: _quickCitiesSuggestions,
        ),
      );
    }
  }

  FutureOr<void> _searchLocation(
    SearchLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(quickCitiesSuggestions: _quickCitiesSuggestions));

    // It is important to `trim` the query before passing it to the repository,
    // otherwise query with trailing spaces will return wrong location.
    final String eventQuery = event.query.trim();

    if (eventQuery.isEmpty) {
      emit(SearchInitial(quickCitiesSuggestions: _quickCitiesSuggestions));
    } else {
      try {
        final Location location = await _locationRepository.getLocation(
          eventQuery,
        );

        emit(
          SearchLocationFound(
            location: location,
            quickCitiesSuggestions: _quickCitiesSuggestions,
          ),
        );
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
        }

        if (e is LocationNotFoundFailure ||
            detailedMessage.contains('LocationNotFoundFailure') ||
            e is NominatimLocationRequestFailure ||
            detailedMessage.contains('NominatimLocationRequestFailure')) {
          emit(
            SearchLocationNotFound(
              query: eventQuery,
              quickCitiesSuggestions: _quickCitiesSuggestions,
            ),
          );
        } else {
          emit(
            SearchError(
              errorMessage: userFriendlyMessage,
              errorType: errorType,
              query: eventQuery,
              quickCitiesSuggestions: _quickCitiesSuggestions,
            ),
          );
        }

        debugPrint(
          '[_searchLocation] '
          'Error type: ${e.runtimeType}\n'
          'errorType: $errorType\n'
          'query: $eventQuery\n'
          'detailedMessage: $detailedMessage\n'
          'Stack trace: $stackTrace',
        );
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      // Test if location services are enabled.
      bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!isServiceEnabled) {
        final geo.Location location = geo.Location();
        isServiceEnabled = await location.requestService();
        if (!isServiceEnabled) {
          throw const LocationServiceDisabledException();
        }
      }
    } catch (e, stackTrace) {
      debugPrint(
        '[_requestLocationPermission] Location service check failed\n'
        'Error type: ${e.runtimeType}\n'
        'Error: $e\n'
        'Stack trace: $stackTrace',
      );
      if (e is LocationServiceDisabledException ||
          e.toString().contains('LOCATION_SERVICES_DISABLED')) {
        throw const LocationServiceDisabledException();
      }
    }
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's `shouldShowRequestPermissionRationale`
        // returned true. According to Android guidelines
        // the App should show an explanatory UI now).
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

  /// Helper method to get the current position with a fallback to the last
  /// known position.
  /// On some platforms (like macOS or Android), requesting a fresh position
  /// immediately after permission is granted can sometimes fail or timeout.
  Future<Position> _getCurrentPosition() async {
    try {
      // Try to get a fresh position with a 10-second timeout.
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return position;
    } catch (e, stackTrace) {
      debugPrint(
        'Geolocator.getCurrentPosition failed\n'
        'Error type: ${e.runtimeType}\n'
        'Error: $e\n'
        'Stack trace: $stackTrace\n'
        'Attempting to get last known position.',
      );
      if (e is PermissionDeniedException) {
        debugPrint(
          '[_getCurrentPosition] Unexpectedly encountered a permission-related '
          'issue despite status being granted. Triggering fallback '
          'verification via _ensureLocationPermission().',
        );
        await _ensureLocationPermission();
      }

      // Fallback to the last known position if getting a fresh one fails.
      final Position lastKnownPosition = await _getLastKnownPosition();
      return lastKnownPosition;
    }
  }

  /// Fallback to the last known position if getting a fresh one fails.
  Future<Position> _getLastKnownPosition() async {
    // Fallback to the last known position if getting a fresh one fails.
    try {
      final Position? lastKnownPosition =
          await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return lastKnownPosition;
      } else {
        debugPrint('Geolocator.getLastKnownPosition() returned null.');
        final Position position = await _getFallbackLocation();
        return position;
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Geolocator.getLastKnownPosition() failed\n'
        'Error type: ${e.runtimeType}\n'
        'Error: $e\n'
        'Stack trace: $stackTrace',
      );
      final Position position = await _getFallbackLocation();
      return position;
    }
  }

  Future<Position> _getFallbackLocation() async {
    final geo.Location location = geo.Location();
    try {
      await _ensureLocationPermission();

      final geo.LocationData locationData = await location.getLocation();
      final double? latitude = locationData.latitude;
      final double? longitude = locationData.longitude;

      if (latitude == null || longitude == null) {
        throw Exception(translate('error.location_unavailable'));
      } else {
        return Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          accuracy: locationData.accuracy ?? 0.0,
          altitude: locationData.altitude ?? 0.0,
          heading: locationData.heading ?? 0.0,
          speed: locationData.speed ?? 0.0,
          speedAccuracy: locationData.speedAccuracy ?? 0.0,
          altitudeAccuracy: locationData.verticalAccuracy ?? 0.0,
          headingAccuracy: locationData.headingAccuracy ?? 0.0,
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Error in _getFallbackLocation\n'
        'Error type: ${e.runtimeType}\n'
        'Error: $e\n'
        'Stack trace: $stackTrace',
      );
      rethrow;
    }
  }

  Future<void> _ensureLocationPermission() async {
    final geo.Location location = geo.Location();
    geo.PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == geo.PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
    } else if (permissionStatus != geo.PermissionStatus.granted &&
        permissionStatus != geo.PermissionStatus.grantedLimited) {
      if (permissionStatus == geo.PermissionStatus.deniedForever) {
        throw Exception(
          translate(
            'error.location_permission_permanently_denied_cannot_request',
          ),
        );
      }
      throw Exception(translate('error.location_permission_denied'));
    }
  }
}
