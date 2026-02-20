import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/app/weather_fit_app.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/di/dependencies.dart';
import 'package:weather_fit/di/injector.dart' as di;
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/router/routes.dart' as router;
import 'package:weather_repository/weather_repository.dart';

/// The [main] is the ultimate detail — the lowest-level policy.
/// It is the initial entry point of the system.
/// Nothing, other than the operating system, depends on it.
/// Here you should [injectDependencies].
/// Think of [main] as a plugin to the [WeatherFitApp] - a plugin that sets up
/// the initial conditions and configurations, gathers all the outside
/// resources, and then hands control over to the high-level policy of the
/// [WeatherFitApp].
/// When [main] is released, it has utterly no effect on any of the other
/// components in the system. They don’t know about [main], and they don’t care
/// when it changes.
void main() async {
  // We need to call `WidgetsFlutterBinding.ensureInitialized` before any
  // `await` operation, otherwise app may stuck on black/white screen.
  WidgetsFlutterBinding.ensureInitialized();

  final Dependencies dependencies = await di.injectDependencies();

  final LocalDataSource localDataSource = dependencies.localDataSource;
  final LocalizationDelegate localizationDelegate =
      dependencies.localizationDelegate;

  final Language initialLanguage = await dependencies
      .initializeAppLanguageUseCase(localizationDelegate);

  final OutfitRepository outfitRepository = dependencies.outfitRepository;

  final WeatherRepository weatherRepository = dependencies.weatherRepository;

  final LocationRepository locationRepository = dependencies.locationRepository;

  final Map<String, WidgetBuilder> routes = router.getRouteMap();

  runApp(
    LocalizedApp(
      localizationDelegate,
      WeatherFitApp(
        weatherRepository: weatherRepository,
        locationRepository: locationRepository,
        outfitRepository: outfitRepository,
        localDataSource: localDataSource,
        initialLanguage: initialLanguage,
        routes: routes,
      ),
    ),
  );
}
