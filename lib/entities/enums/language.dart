/// [Language] is an `enum` object that contains all supported languages by
/// project.
enum Language {
  en(
    name: _englishLanguage,
    isoLanguageCode: _englishIsoLanguageCode,
    flag: '🇬🇧',
  ),
  uk(
    name: _ukrainianLanguage,
    isoLanguageCode: _ukrainianIsoLanguageCode,
    flag: '🇺🇦',
  ),
  pl(
    name: _polishLanguage,
    isoLanguageCode: _polishIsoLanguageCode,
    flag: '🇵🇱',
  );

  const Language({
    required this.name,
    required this.isoLanguageCode,
    required this.flag,
  });

  final String name;
  final String isoLanguageCode;
  final String flag;

  bool get isEnglish => this == Language.en;

  static Language fromIsoLanguageCode(String isoLanguageCode) {
    switch (isoLanguageCode.trim().toLowerCase()) {
      case _englishIsoLanguageCode:
        return Language.en;
      case _ukrainianIsoLanguageCode:
        return Language.uk;
      case _polishIsoLanguageCode:
        return Language.pl;
      default:
        return Language.en;
    }
  }
}

const String _englishIsoLanguageCode = 'en';
const String _ukrainianIsoLanguageCode = 'uk';
const String _polishIsoLanguageCode = 'pl';
const String _englishLanguage = 'English';
const String _ukrainianLanguage = 'Ukrainian';
const String _polishLanguage = 'Polish';
