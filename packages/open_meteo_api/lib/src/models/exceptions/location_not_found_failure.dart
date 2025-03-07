/// Exception thrown when the provided location is not found.
class LocationNotFoundFailure implements Exception {
  const LocationNotFoundFailure();

  @override
  String toString() {
    return 'The location you have entered does not exist in our database or '
        'has a typo.';
  }
}
