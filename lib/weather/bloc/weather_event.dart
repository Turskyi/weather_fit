part of 'weather_bloc.dart';

@immutable
sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => <Object>[];
}

final class FetchWeather extends WeatherEvent {
  const FetchWeather({required this.location});

  final String location;

  @override
  List<Object> get props => <Object>[location];
}

final class RefreshWeather extends WeatherEvent {
  const RefreshWeather();
}

final class ToggleUnits extends WeatherEvent {
  const ToggleUnits();
}

final class UpdateWeatherOnMobileHomeScreenEvent extends WeatherEvent {
  const UpdateWeatherOnMobileHomeScreenEvent();
}
