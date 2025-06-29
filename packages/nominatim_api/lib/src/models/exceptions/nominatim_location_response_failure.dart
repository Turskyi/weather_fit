/// Exception thrown when decoding the response fails.
class NominatimLocationResponseFailure implements Exception {
  const NominatimLocationResponseFailure();

  @override
  String toString() => 'Malformed location response.';
}
