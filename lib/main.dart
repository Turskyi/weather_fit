import 'package:dio/dio.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:nominatim_api/nominatim_api.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:weather_fit/app/weather_fit_app.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/data_sources/remote/remote_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/di/injector.dart' as di;
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/feedback/feedback_form.dart';
import 'package:weather_fit/localization/localization_delelegate_getter.dart'
    as locale;
import 'package:weather_fit/router/app_route.dart';
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

  await di.injectDependencies();

  final SharedPreferences preferences = await SharedPreferences.getInstance();

  final LocalDataSource localDataSource = LocalDataSource(preferences);
  final RemoteDataSource remoteDataSource = RemoteDataSource(Dio());

  Language initialLanguage = localDataSource.getSavedLanguage();

  if (kIsWeb) {
    // Retrieves the host name (e.g., "localhost" or "uk.weather-fit.com").
    initialLanguage = await _resolveInitialLanguageFromUrl(
      initialLanguage: initialLanguage,
      localDataSource: localDataSource,
    );
  }

  final LocalizationDelegate localizationDelegate = await locale
      .getLocalizationDelegate(localDataSource);

  final Language currentLanguage = Language.fromIsoLanguageCode(
    localizationDelegate.currentLocale.languageCode,
  );

  if (initialLanguage != currentLanguage) {
    _applyInitialLocale(
      initialLanguage: initialLanguage,
      localizationDelegate: localizationDelegate,
    );
  }

  runApp(
    LocalizedApp(
      localizationDelegate,
      BetterFeedback(
        feedbackBuilder:
            (
              BuildContext _,
              OnSubmit onSubmit,
              ScrollController? scrollController,
            ) {
              return FeedbackForm(
                onSubmit: onSubmit,
                scrollController: scrollController,
              );
            },
        theme: FeedbackThemeData(feedbackSheetColor: Colors.grey.shade50),
        child: WeatherFitApp(
          weatherRepository: WeatherRepository(),
          locationRepository: LocationRepository(
            NominatimApiClient(),
            OpenMeteoApiClient(),
            localDataSource,
          ),
          outfitRepository: OutfitRepository(localDataSource, remoteDataSource),
          localDataSource: localDataSource,
          initialLanguage: initialLanguage,
        ),
      ),
    ),
  );
}

void _applyInitialLocale({
  required Language initialLanguage,
  required LocalizationDelegate localizationDelegate,
}) {
  final Locale locale = localeFromString(initialLanguage.isoLanguageCode);

  localizationDelegate.changeLocale(locale);

  // Notify listeners that the locale has changed so they can update.
  localizationDelegate.onLocaleChanged?.call(locale);
}

Future<Language> _resolveInitialLanguageFromUrl({
  required Language initialLanguage,
  required LocalDataSource localDataSource,
}) async {
  // Retrieves the host name (e.g., "localhost" or "uk.weather-fit.com").
  final String host = Uri.base.host;

  // Retrieves the fragment (e.g., "/en" or "/uk").
  final String fragment = Uri.base.fragment;

  for (final Language language in Language.values) {
    final String currentLanguageCode = language.isoLanguageCode;
    if (host.startsWith('$currentLanguageCode.') ||
        fragment.contains('${AppRoute.weather.path}$currentLanguageCode')) {
      try {
        Intl.defaultLocale = currentLanguageCode;
      } catch (e, stackTrace) {
        debugPrint(
          'Failed to set Intl.defaultLocale to "$currentLanguageCode".\n'
          'Error: $e\n'
          'StackTrace: $stackTrace\n'
          'Proceeding with previously set default locale or system default.',
        );
      }
      initialLanguage = language;
      // We save it so the rest of the app (like recommendations) uses this
      // language.
      await localDataSource.saveLanguageIsoCode(currentLanguageCode);
      break;
    }
  }
  return initialLanguage;
}
