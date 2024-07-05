part of 'weather_bloc.dart';

@immutable
sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => <Object>[];
}

class FetchWeather extends WeatherEvent {
  const FetchWeather({required this.city});

  final String city;

  @override
  List<Object> get props => <Object>[city];
}

class RefreshWeather extends WeatherEvent {
  const RefreshWeather();
}

class ToggleUnits extends WeatherEvent {
  const ToggleUnits();
}
