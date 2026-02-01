part of 'search_bloc.dart';

@immutable
sealed class SearchState {
  const SearchState({required this.quickCitiesSuggestions});

  final List<QuickCitySuggestion> quickCitiesSuggestions;
}

final class SearchInitial extends SearchState {
  const SearchInitial({required super.quickCitiesSuggestions});
}

final class SearchLoading extends SearchState {
  const SearchLoading({required super.quickCitiesSuggestions});
}

final class SearchLocationFound extends SearchState {
  const SearchLocationFound({
    required this.location,
    required super.quickCitiesSuggestions,
  });

  final Location location;
}

final class SearchLocationNotFound extends SearchState {
  const SearchLocationNotFound({
    required this.query,
    required super.quickCitiesSuggestions,
  });

  final String query;
}

final class SearchError extends SearchState {
  const SearchError({
    required this.errorMessage,
    required this.query,
    required this.errorType,
    required super.quickCitiesSuggestions,
  });

  final String errorMessage;
  final SearchErrorType errorType;
  final String query;

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
  const SearchWeatherLoaded({
    required this.weather,
    required super.quickCitiesSuggestions,
  });

  final Weather weather;
}
