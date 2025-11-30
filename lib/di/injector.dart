import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/services/home_widget_service.dart';
import 'package:weather_fit/weather_bloc_observer.dart';
import 'package:weather_repository/weather_repository.dart';
import 'package:workmanager/workmanager.dart';

Future<void> injectDependencies() async {
  await _initializeAllDateFormatting();
  // Make sure we run on supported platforms:
  // https://pub.dev/packages/workmanager
  if (!kIsWeb && !Platform.isMacOS && (Platform.isAndroid || Platform.isIOS)) {
    try {
      Workmanager().initialize(_callbackDispatcher).then((void _) {
        try {
          Workmanager().registerPeriodicTask(
            'weatherfit_background_update',
            'updateWidgetTask',
            // Home widget will be updated every two hours.
            frequency: const Duration(minutes: 120),
            constraints: Constraints(networkType: NetworkType.connected),
          );
        } catch (e) {
          debugPrint(
            'Background widget update failed in '
            'Workmanager.registerPeriodicTask: $e',
          );
        }
      });
    } catch (e) {
      debugPrint(
        'Background widget update failed in Workmanager.initialize: $e',
      );
    }
  }

  Bloc.observer = const WeatherBlocObserver();

  if (kIsWeb) {
    try {
      final HydratedStorage hydratedStorage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory.web,
      );
      HydratedBloc.storage = hydratedStorage;
    } catch (e) {
      debugPrint('Failed to initialize hydrated storage on web: $e');
    }
  } else {
    try {
      // We cannot specify `Directory` type here, otherwise it will not work on
      // Web.
      final dynamic temporaryDirectory = await getTemporaryDirectory();
      final HydratedStorage hydratedStorage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory(temporaryDirectory.path),
      );
      HydratedBloc.storage = hydratedStorage;
    } catch (e, s) {
      debugPrint('Failed to initialize hydrated storage: $e.\nStackTrace: $s');
    }
  }
}

/// Used for Background Updates using [Workmanager] Plugin.
@pragma('vm:entry-point')
void _callbackDispatcher() {
  try {
    Workmanager().executeTask((String _, Map<String, Object?>? _) async {
      try {
        WidgetsFlutterBinding.ensureInitialized();

        await _initializeAllDateFormatting();

        final SharedPreferences preferences =
            await SharedPreferences.getInstance();

        final LocalDataSource localDataSource = LocalDataSource(preferences);

        final Location lastSavedLocation = localDataSource
            .getLastSavedLocation();

        if (lastSavedLocation.isNotEmpty) {
          // Get latest weather.
          final WeatherRepository weatherRepository = WeatherRepository();

          final WeatherDomain domainWeather = await weatherRepository
              .getWeatherByLocation(lastSavedLocation);

          final DailyForecastDomain dailyForecast = await weatherRepository
              .getDailyForecast(lastSavedLocation);

          final OutfitRepository outfitRepository = OutfitRepository(
            localDataSource,
          );

          final HomeWidgetService homeWidgetService =
              const HomeWidgetServiceImpl();

          final Weather weather = Weather.fromRepository(domainWeather);

          await homeWidgetService.updateHomeWidget(
            localDataSource: localDataSource,
            weather: weather,
            outfitRepository: outfitRepository,
            forecast: dailyForecast,
          );

          return true;
        } else {
          return false;
        }
      } catch (e) {
        debugPrint('Background widget update failed: $e');
        return false;
      }
    });
  } catch (e) {
    debugPrint('Error while WorkManager.executeTask: $e');
  }
}

Future<void> _initializeAllDateFormatting() async {
  for (Language lang in Language.values) {
    try {
      await initializeDateFormatting(lang.isoLanguageCode, null);
    } catch (e, stackTrace) {
      debugPrint(
        'Failed to initialize date formatting for ${lang.isoLanguageCode}.\n'
        'Error: $e\n'
        'StackTrace: $stackTrace',
      );
    }
  }
}

/// Called when Doing Background Work initiated from Widget
@pragma('vm:entry-point')
Future<void> _interactiveCallback(Uri? data) async {
  //TODO: add implementation.
}
