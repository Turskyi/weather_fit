import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_repository/weather_repository.dart';

Future<LocalizationDelegate> getLocalizationDelegate(
  Language savedLanguage,
) async {
  final LocalizationDelegate localizationDelegate =
      await LocalizationDelegate.create(
        fallbackLocale: savedLanguage.isoLanguageCode,
        supportedLocales: Language.values
            .map((Language language) => language.isoLanguageCode)
            .toList(),
      );

  return localizationDelegate;
}
