import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/router/app_route.dart';

/// Use case for initializing the application's language during startup.
///
/// Responsible for:
/// 1. Retrieving the saved language preference
/// 2. Resolving language from URL on web platforms
/// 3. Applying the resolved language to the localization delegate
/// 4. Returning the initial language to be used by the app
class InitializeAppLanguageUseCase {
  const InitializeAppLanguageUseCase({required LocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final LocalDataSource _localDataSource;

  /// Executes the language initialization flow.
  ///
  /// Returns the [Language] to be used for the app.
  Future<Language> call(LocalizationDelegate localizationDelegate) async {
    Language initialLanguage = _localDataSource.getSavedLanguage();

    if (kIsWeb) {
      initialLanguage = await _resolveLanguageFromUrl(
        initialLanguage: initialLanguage,
      );
    }

    final Language currentLanguage = Language.fromIsoLanguageCode(
      localizationDelegate.currentLocale.languageCode,
    );

    if (initialLanguage != currentLanguage) {
      _applyLanguage(
        language: initialLanguage,
        localizationDelegate: localizationDelegate,
      );
    }

    return initialLanguage;
  }

  /// Resolves the language from the URL path or host on web.
  Future<Language> _resolveLanguageFromUrl({
    required Language initialLanguage,
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
        await _localDataSource.saveLanguageIsoCode(currentLanguageCode);
        break;
      }
    }
    return initialLanguage;
  }

  /// Applies the language to the localization delegate.
  void _applyLanguage({
    required Language language,
    required LocalizationDelegate localizationDelegate,
  }) {
    final Locale locale = localeFromString(language.isoLanguageCode);

    localizationDelegate.changeLocale(locale);

    // Notify listeners that the locale has changed so they can update.
    localizationDelegate.onLocaleChanged?.call(locale);
  }
}
