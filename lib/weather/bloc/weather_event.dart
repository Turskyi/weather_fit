part of 'weather_bloc.dart';

@immutable
sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => <Object>[];
}

final class FetchWeather extends WeatherEvent {
  const FetchWeather({required this.location, required this.origin});

  final Location location;
  final WeatherFetchOrigin origin;

  @override
  List<Object> get props => <Object>[location, origin];
}

final class RefreshWeather extends WeatherEvent {
  const RefreshWeather(this.origin);

  final WeatherFetchOrigin origin;

  @override
  List<Object> get props => <Object>[origin];
}

final class ToggleUnits extends WeatherEvent {
  const ToggleUnits();
}

final class UpdateWeatherOnHomeWidgetEvent extends WeatherEvent {
  const UpdateWeatherOnHomeWidgetEvent(this.origin);

  final WeatherFetchOrigin origin;

  @override
  List<Object> get props => <Object>[origin];
}

final class GetOutfitEvent extends WeatherEvent {
  const GetOutfitEvent({required this.weather, required this.origin});

  final Weather weather;
  final WeatherFetchOrigin origin;

  @override
  List<Object> get props => <Object>[weather, origin];
}

final class FetchDailyForecast extends WeatherEvent {
  const FetchDailyForecast({required this.location});

  final Location location;

  @override
  List<Object> get props => <Object>[location];
}

final class CheckHourChangeOnResume extends WeatherEvent {
  const CheckHourChangeOnResume(this.origin);

  final WeatherFetchOrigin origin;
}

final class ToggleFavouriteEvent extends WeatherEvent {
  const ToggleFavouriteEvent(this.location);

  final Location location;

  @override
  List<Object> get props => <Object>[location];
}
