/// Exception thrown when weather request fails.
class WeatherRequestFailure implements Exception {
  /// {@macro weather_request_failure}
  const WeatherRequestFailure({
    this.message = 'Weather request failed',
    this.statusCode,
  });

  /// The message associated with the failure.
  final String message;

  /// The HTTP status code of the failure.
  final int? statusCode;

  @override
  String toString() {
    return 'WeatherRequestFailure(message: $message, statusCode: $statusCode)';
  }
}
