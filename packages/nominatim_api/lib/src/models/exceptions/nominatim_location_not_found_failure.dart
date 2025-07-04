/// Exception thrown when the response does not contain a valid result.
class NominatimLocationNotFoundFailure implements Exception {
  const NominatimLocationNotFoundFailure();

  @override
  String toString() {
    return 'The location you have entered does not exist in our database or '
        'has a typo.';
  }
}
