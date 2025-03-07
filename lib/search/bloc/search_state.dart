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

final class SearchError extends SearchState {
  const SearchError(this.errorMessage);

  final String errorMessage;
}

final class SearchWeatherLoaded extends SearchState {
  const SearchWeatherLoaded(this.weather);

  final Weather weather;
}
