/// Exception thrown when the weather response is malformed.
class WeatherResponseFailure implements Exception {
  const WeatherResponseFailure();

  @override
  String toString() => 'Malformed weather response.';
}
