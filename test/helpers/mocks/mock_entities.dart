import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart';

class MockWeatherDomain extends Mock implements WeatherDomain {
  MockWeatherDomain();
}

class FakeLocation extends Fake implements Location {
  FakeLocation();
}
