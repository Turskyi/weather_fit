part of 'search_bloc.dart';

@immutable
sealed class SearchState {
  const SearchState();
}

final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchLocationFound extends SearchState {
  const SearchLocationFound(this.location);

  final Location location;
}

final class SearchLocationNotFound extends SearchState {
  const SearchLocationNotFound(this.query);

  final String query;
}

final class SearchError extends SearchState {
  const SearchError({
    required this.errorMessage,
    this.errorType = SearchErrorType.unknown,
  });

  final String errorMessage;
  final SearchErrorType errorType;

  /// Returns `true` if the error is due to a certificate validation failure.
  bool get isCertificateValidationError {
    return errorType.isCertificateValidationError;
  }

  /// Returns `true` if the error is due to a network failure.
  bool get isNetworkError => errorType.isNetworkError;

  /// Returns `true` if the error is due to permanently denied location
  /// permissions.
  bool get isPermissionDeniedError {
    return errorType.isPermissionDeniedPermanentlyError;
  }
}

final class SearchWeatherLoaded extends SearchState {
  const SearchWeatherLoaded(this.weather);

  final Weather weather;
}
