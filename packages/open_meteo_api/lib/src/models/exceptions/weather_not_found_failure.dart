/// Exception thrown when weather for provided location is not found.
class WeatherNotFoundFailure implements Exception {
  const WeatherNotFoundFailure();

  @override
  String toString() => 'Weather not found.';
}
