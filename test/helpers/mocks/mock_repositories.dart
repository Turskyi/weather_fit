import 'package:mocktail/mocktail.dart';
import 'package:weather_fit/data/repositories/ai_repository.dart';
import 'package:weather_repository/weather_repository.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockAiRepository extends Mock implements AiRepository {}
