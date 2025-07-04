import 'package:mocktail/mocktail.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_repository/weather_repository.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockOutfitRepository extends Mock implements OutfitRepository {}
