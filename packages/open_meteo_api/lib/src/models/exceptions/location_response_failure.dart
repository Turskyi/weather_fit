/// Exception thrown when the location response is malformed.
class LocationResponseFailure implements Exception {
  const LocationResponseFailure();

  @override
  String toString() => 'Malformed location response.';
}
