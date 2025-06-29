import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/enums/language.dart';

Future<LocalizationDelegate> getLocalizationDelegate(
  LocalDataSource localDataSource,
) async {
  final Language savedLanguage = Language.fromIsoLanguageCode(
    localDataSource.getLanguageIsoCode(),
  );

  final String fallbackLocale = Language.fromIsoLanguageCode(
    savedLanguage.isoLanguageCode,
  ).isoLanguageCode;

  final LocalizationDelegate localizationDelegate =
      await LocalizationDelegate.create(
    fallbackLocale: fallbackLocale,
    supportedLocales: Language.values
        .map((Language language) => language.isoLanguageCode)
        .toList(),
  );
  return localizationDelegate;
}
