import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/data_sources/remote/remote_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/di/use_cases/initialize_app_language_use_case.dart';
import 'package:weather_repository/weather_repository.dart';

/// Holds all core dependencies required by the application.
class Dependencies {
  const Dependencies({
    required this.preferences,
    required this.localDataSource,
    required this.remoteDataSource,
    required this.outfitRepository,
    required this.weatherRepository,
    required this.locationRepository,
    required this.initializeAppLanguageUseCase,
    required this.localizationDelegate,
  });

  final SharedPreferences preferences;
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;
  final OutfitRepository outfitRepository;
  final WeatherRepository weatherRepository;
  final LocationRepository locationRepository;
  final InitializeAppLanguageUseCase initializeAppLanguageUseCase;
  final LocalizationDelegate localizationDelegate;
}
