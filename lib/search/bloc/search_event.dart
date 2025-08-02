part of 'search_bloc.dart';

@immutable
sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => <Object>[];
}

final class SearchLocation extends SearchEvent {
  const SearchLocation(this.query);

  final String query;

  @override
  List<Object> get props => <Object>[query];
}

final class ConfirmLocation extends SearchEvent {
  const ConfirmLocation(this.location);

  final Location location;

  @override
  List<Object> get props => <Object>[location];
}

final class SearchByLocation extends SearchEvent {
  const SearchByLocation({required this.latitude, required this.longitude});

  /// The latitude of this position in degrees normalized to the interval -90.0
  /// to +90.0 (both inclusive).
  final double latitude;

  /// The longitude of the position in degrees normalized to the interval -180
  /// (exclusive) to +180 (inclusive).
  final double longitude;
}

final class RequestPermissionAndSearchByLocation extends SearchEvent {
  const RequestPermissionAndSearchByLocation();
}
