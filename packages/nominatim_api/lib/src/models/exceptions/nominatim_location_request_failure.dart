/// Exception thrown when the response does not contain a valid result.
class NominatimLocationRequestFailure implements Exception {
  const NominatimLocationRequestFailure();

  @override
  String toString() => 'Location request failed.';
}
