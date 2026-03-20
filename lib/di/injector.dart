import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nominatim_api/nominatim_api.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/data_sources/remote/remote_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/di/dependencies.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/localization/localization_delegate_getter.dart'
    as locale;
import 'package:weather_fit/res/constants/constants.dart' as constants;
import 'package:weather_fit/services/home_widget_service.dart';
import 'package:weather_fit/services/home_widget_service_impl.dart';
import 'package:weather_fit/use_cases/initialize_app_language_use_case.dart';
import 'package:weather_fit/weather_bloc_observer.dart';
import 'package:weather_repository/weather_repository.dart';
import 'package:workmanager/workmanager.dart';

Future<Dependencies> injectDependencies() async {
  await _initializeAllDateFormatting();

  Bloc.observer = const WeatherBlocObserver();

  if (kIsWeb) {
    await _initializeWebHydratedStorage();
  } else {
    await _setupMobileHydratedStorage();
  }

  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final LocalDataSource localDataSource = LocalDataSource(preferences);

  // Make sure we run on supported platforms:
  // https://pub.dev/packages/workmanager
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    _setupBackgroundWidgetUpdates(localDataSource);
  }

  final RemoteDataSource remoteDataSource = RemoteDataSource(Dio());
  final OutfitRepository outfitRepository = OutfitRepository(
    localDataSource,
    remoteDataSource,
  );
  final WeatherRepository weatherRepository = WeatherRepository();
  final LocationRepository locationRepository = LocationRepository(
    NominatimApiClient(),
    OpenMeteoApiClient(),
    localDataSource,
  );
  final InitializeAppLanguageUseCase initializeAppLanguageUseCase =
      InitializeAppLanguageUseCase(localDataSource: localDataSource);

  final Language savedLanguage = localDataSource.getSavedLanguage();
  final LocalizationDelegate localizationDelegate = await locale
      .getLocalizationDelegate(savedLanguage);

  return Dependencies(
    preferences: preferences,
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    outfitRepository: outfitRepository,
    weatherRepository: weatherRepository,
    locationRepository: locationRepository,
    initializeAppLanguageUseCase: initializeAppLanguageUseCase,
    localizationDelegate: localizationDelegate,
  );
}

Future<void> _setupMobileHydratedStorage() async {
  // We cannot specify `Directory` type here, otherwise it will not work on
  // Web.
  final dynamic temporaryDirectory = await getTemporaryDirectory();
  final String storagePath = temporaryDirectory.path;

  try {
    final HydratedStorage hydratedStorage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(storagePath),
    );
    HydratedBloc.storage = hydratedStorage;
    return;
  } catch (e, s) {
    debugPrint('Failed to initialize hydrated storage: $e.\nStackTrace: $s');
  }

  // If the lock file got stuck from a previous process, clear it and retry.
  try {
    final File lockFile = File('$storagePath/hydrated_box.lock');
    if (await lockFile.exists()) {
      await lockFile.delete();
    }

    final HydratedStorage hydratedStorage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(storagePath),
    );
    HydratedBloc.storage = hydratedStorage;
    return;
  } catch (e, s) {
    debugPrint(
      'Retry after clearing hydrated storage lock failed: $e.\nStackTrace: $s',
    );
  }

  // Final fallback: use an isolated temporary folder so the app can still boot.
  final String fallbackStoragePath =
      '$storagePath/hydrated_fallback_${DateTime.now().millisecondsSinceEpoch}';
  await Directory(fallbackStoragePath).create(recursive: true);

  final HydratedStorage fallbackStorage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(fallbackStoragePath),
  );
  HydratedBloc.storage = fallbackStorage;
}

Future<void> _initializeWebHydratedStorage() async {
  try {
    final HydratedStorage hydratedStorage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory.web,
    );
    HydratedBloc.storage = hydratedStorage;
  } catch (e) {
    debugPrint('Failed to initialize hydrated storage on web: $e');
  }
}

/// Initializes background widget updates using Workmanager plugin.
///
/// **iOS BACKGROUND TASK BEHAVIOR (Critical Understanding)**
///
/// On iOS, background task execution is NOT guaranteed and is controlled
/// entirely by the OS.
/// This is a fundamental iOS limitation, NOT a bug in our implementation.
///
/// **Key iOS Constraints:**
/// - Minimum frequency: 15 minutes (but this is merely a floor; actual
/// execution is much less frequent)
/// - Actual execution frequency: ~1 per day (controlled by iOS based on user
/// behavior & battery state)
/// - No guarantee: iOS may never execute the task, especially if:
///   - User hasn't opened the app recently
///   - Device is in low-power mode
///   - App is not frequently used (iOS throttles background tasks for
///   rarely-used apps)
///   - User has disabled "Background App Refresh" in iOS Settings
/// - Task execution limits: ~30 seconds for standard background fetch tasks
/// - Cannot be forced: Unlike Android, iOS does not guarantee background task
/// execution
///
/// **Comparison with Android:**
/// - Android: Workmanager respects minimum 15-minute frequency and is more
/// predictable
/// - iOS: Frequency is a suggestion; OS schedules based on app usage patterns
/// and device state
///
/// **What we're doing correctly:**
/// ✅ Registering task with configurable frequency
/// ✅ Using NetworkType.connected constraint to avoid draining battery
/// ✅ Handling errors gracefully with try-catch and debug logging
/// ✅ Using @pragma('vm:entry-point') for callback dispatcher
/// ✅ Initializing all necessary dependencies in background context
///
/// **Expected behavior on iOS:**
/// - Widget may update ~1-2 times per day when iOS decides to execute
/// background fetch
/// - Updates are NOT tied to the frequency we request; that's just a hint
/// - Device state, battery, and user behavior are primary factors in iOS
/// scheduling
/// - This is why widget updates on iOS appear irregular and unpredictable
///
/// **References:**
/// - https://pub.dev/packages/workmanager (iOS limitations documented)
/// - https://developer.apple.com/documentation/backgroundtasks
/// - Apple's BGTaskScheduler APIs have hard execution time limits
///
Future<void> _setupBackgroundWidgetUpdates(
  LocalDataSource localDataSource,
) async {
  try {
    await Workmanager().initialize(_callbackDispatcher);
    final int frequencyMinutes = localDataSource.getWidgetUpdateFrequency();
    try {
      await Workmanager().registerPeriodicTask(
        constants.kBackgroundUniqueName,
        constants.kBackgroundTaskName,
        // Request frequency, but iOS will schedule based on its own heuristics.
        // On iOS, actual execution may be much less frequent (~1x daily).
        // This is an OS-level limitation, not a configuration issue.
        frequency: Duration(minutes: frequencyMinutes),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    } catch (e) {
      debugPrint(
        'Background widget update failed in '
        'Workmanager.registerPeriodicTask: $e',
      );
    }
  } catch (e) {
    debugPrint('Background widget update failed in Workmanager.initialize: $e');
  }
}

/// Used for Background Updates using [Workmanager] Plugin.
@pragma('vm:entry-point')
void _callbackDispatcher() {
  try {
    Workmanager().executeTask((String _, Map<String, Object?>? _) async {
      return _performWidgetUpdateTick();
    });
  } catch (e) {
    debugPrint('Error while WorkManager.executeTask: $e');
  }
}

Future<bool> _performWidgetUpdateTick() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await _initializeAllDateFormatting();

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final LocalDataSource localDataSource = LocalDataSource(preferences);
    final RemoteDataSource remoteDataSource = RemoteDataSource(Dio());

    final HomeWidgetService homeWidgetService = const HomeWidgetServiceImpl();

    // Save currently selected language to widget data so native widgets
    // (Android/iOS/macOS) can use it to localize strings.
    try {
      final String languageCode = localDataSource.getLanguageIsoCode();
      await homeWidgetService.saveWidgetData<String>(
        'selected_language',
        languageCode,
      );
    } catch (e) {
      debugPrint('Failed to save widget language: $e');
    }

    final Location lastSavedLocation = localDataSource.getLastSavedLocation();

    if (lastSavedLocation.isEmpty) {
      return false;
    }

    final WeatherRepository weatherRepository = WeatherRepository();

    final WeatherDomain domainWeather = await weatherRepository
        .getWeatherByLocation(lastSavedLocation);

    final DailyForecastDomain dailyForecast = await weatherRepository
        .getDailyForecast(lastSavedLocation);

    final OutfitRepository outfitRepository = OutfitRepository(
      localDataSource,
      remoteDataSource,
    );

    final Weather weather = Weather.fromRepository(domainWeather);

    await homeWidgetService.updateHomeWidget(
      localDataSource: localDataSource,
      weather: weather,
      outfitRepository: outfitRepository,
      forecast: dailyForecast,
    );

    return true;
  } catch (e) {
    debugPrint('Background widget update failed: $e');
    return false;
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
