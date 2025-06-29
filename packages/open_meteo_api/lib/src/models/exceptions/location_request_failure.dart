/// Exception thrown when locationSearch fails.
class LocationRequestFailure implements Exception {
  const LocationRequestFailure();

  @override
  String toString() => 'Location request failed.';
}
