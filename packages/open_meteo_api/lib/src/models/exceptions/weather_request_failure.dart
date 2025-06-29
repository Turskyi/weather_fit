/// Exception thrown when getWeather fails.
class WeatherRequestFailure implements Exception {
  const WeatherRequestFailure();

  @override
  String toString() => 'Weather request failed';
}
