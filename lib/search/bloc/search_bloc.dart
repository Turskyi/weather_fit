import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._weatherRepository) : super(const SearchInitial()) {
    on<SearchLocation>(_searchLocation);
    on<ConfirmLocation>(_confirmLocation);
    on<SearchByLocation>(_searchByLocation);
    on<RequestPermissionAndSearchByLocation>(_onRequestLocationPermission);
  }

  final WeatherRepository _weatherRepository;

  FutureOr<void> _searchByLocation(
    SearchByLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());
    try {
      final WeatherDomain weather =
          await _weatherRepository.getWeatherByLocation(
        Location(latitude: event.latitude, longitude: event.longitude),
      );
      emit(SearchWeatherLoaded(Weather.fromRepository(weather)));
    } catch (e) {
      emit(SearchError('Error getting weather: $e'));
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
    } catch (e) {
      emit(SearchError('Error getting weather: $e'));
    }
  }

  FutureOr<void> _searchLocation(
    SearchLocation event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());
    try {
      final Location location = await _weatherRepository.getLocation(
        event.query,
      );

      emit(SearchLocationFound(location));
    } catch (e) {
      emit(SearchError('Error searching for location: $e'));
    }
  }

  Future<void> _onRequestLocationPermission(
    _,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());
    try {
      await _requestLocationPermission();

      final Position position = await Geolocator.getCurrentPosition();

      final WeatherDomain weather =
          await _weatherRepository.getWeatherByLocation(
        Location(latitude: position.latitude, longitude: position.longitude),
      );
      emit(SearchWeatherLoaded(Weather.fromRepository(weather)));
    } catch (e) {
      emit(SearchError('Error getting weather: $e'));
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
        // your App should show an explanatory UI now.
        return Future<void>.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future<void>.error(
        'Location permissions are permanently denied, we cannot request '
        'permissions.',
      );
    }
  }
}
