part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {
  const SettingsState({
    required this.language,
    this.appVersion,
    this.widgetUpdateFrequency = 120,
    this.dayStartHour = WeatherCondition.defaultDayStartHour,
    this.nightStartHour = WeatherCondition.defaultNightStartHour,
    this.debugWeatherProviderOpenWeatherMap = false,
  });

  final Language language;
  final String? appVersion;
  final int widgetUpdateFrequency;
  final int dayStartHour;
  final int nightStartHour;
  final bool debugWeatherProviderOpenWeatherMap;

  bool get isEnglish => language == Language.en;

  bool get isUkrainian => language == Language.uk;

  String get locale => language.isoLanguageCode;

  String get languageIsoCode => language.isoLanguageCode;

  SettingsState copyWith({
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
    int? dayStartHour,
    int? nightStartHour,
    bool? debugWeatherProviderOpenWeatherMap,
  });
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial({
    required super.language,
    super.appVersion,
    super.widgetUpdateFrequency,
    super.dayStartHour,
    super.nightStartHour,
    super.debugWeatherProviderOpenWeatherMap,
  });

  @override
  SettingsInitial copyWith({
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
    int? dayStartHour,
    int? nightStartHour,
    bool? debugWeatherProviderOpenWeatherMap,
  }) {
    return SettingsInitial(
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      widgetUpdateFrequency:
          widgetUpdateFrequency ?? this.widgetUpdateFrequency,
      dayStartHour: dayStartHour ?? this.dayStartHour,
      nightStartHour: nightStartHour ?? this.nightStartHour,
      debugWeatherProviderOpenWeatherMap:
          debugWeatherProviderOpenWeatherMap ??
          this.debugWeatherProviderOpenWeatherMap,
    );
  }

  @override
  String toString() {
    return 'SettingsInitial{'
        '  language: $language,'
        '  appVersion: $appVersion,'
        '  widgetUpdateFrequency: $widgetUpdateFrequency,'
        '  dayStartHour: $dayStartHour,'
        '  nightStartHour: $nightStartHour,'
        '  debugWeatherProviderOpenWeatherMap: '
        '$debugWeatherProviderOpenWeatherMap'
        '}';
  }
}

final class FeedbackState extends SettingsState {
  const FeedbackState({
    required this.errorMessage,
    required super.language,
    super.appVersion,
    super.widgetUpdateFrequency,
    super.dayStartHour,
    super.nightStartHour,
    super.debugWeatherProviderOpenWeatherMap,
  });

  final String errorMessage;

  @override
  String toString() {
    return 'FeedbackState('
        '  errorMessage: $errorMessage,'
        '  language: $language,'
        '  appVersion: $appVersion,'
        '  widgetUpdateFrequency: $widgetUpdateFrequency,'
        '  dayStartHour: $dayStartHour,'
        '  nightStartHour: $nightStartHour,'
        '  debugWeatherProviderOpenWeatherMap: '
        '$debugWeatherProviderOpenWeatherMap'
        ')';
  }

  @override
  FeedbackState copyWith({
    String? errorMessage,
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
    int? dayStartHour,
    int? nightStartHour,
    bool? debugWeatherProviderOpenWeatherMap,
  }) {
    return FeedbackState(
      errorMessage: errorMessage ?? this.errorMessage,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      widgetUpdateFrequency:
          widgetUpdateFrequency ?? this.widgetUpdateFrequency,
      dayStartHour: dayStartHour ?? this.dayStartHour,
      nightStartHour: nightStartHour ?? this.nightStartHour,
      debugWeatherProviderOpenWeatherMap:
          debugWeatherProviderOpenWeatherMap ??
          this.debugWeatherProviderOpenWeatherMap,
    );
  }
}

final class FeedbackSent extends SettingsState {
  const FeedbackSent({
    required super.language,
    super.appVersion,
    super.widgetUpdateFrequency,
    super.dayStartHour,
    super.nightStartHour,
    super.debugWeatherProviderOpenWeatherMap,
  });

  @override
  String toString() {
    return 'FeedbackSent('
        '  language: $language,'
        '  appVersion: $appVersion,'
        '  widgetUpdateFrequency: $widgetUpdateFrequency,'
        '  dayStartHour: $dayStartHour,'
        '  nightStartHour: $nightStartHour,'
        '  debugWeatherProviderOpenWeatherMap: '
        '$debugWeatherProviderOpenWeatherMap'
        ')';
  }

  @override
  FeedbackSent copyWith({
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
    int? dayStartHour,
    int? nightStartHour,
    bool? debugWeatherProviderOpenWeatherMap,
  }) {
    return FeedbackSent(
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      widgetUpdateFrequency:
          widgetUpdateFrequency ?? this.widgetUpdateFrequency,
      dayStartHour: dayStartHour ?? this.dayStartHour,
      nightStartHour: nightStartHour ?? this.nightStartHour,
      debugWeatherProviderOpenWeatherMap:
          debugWeatherProviderOpenWeatherMap ??
          this.debugWeatherProviderOpenWeatherMap,
    );
  }
}

final class LoadingSettingsState extends SettingsState {
  const LoadingSettingsState({
    required super.language,
    super.appVersion,
    super.widgetUpdateFrequency,
    super.dayStartHour,
    super.nightStartHour,
    super.debugWeatherProviderOpenWeatherMap,
  });

  @override
  LoadingSettingsState copyWith({
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
    int? dayStartHour,
    int? nightStartHour,
    bool? debugWeatherProviderOpenWeatherMap,
  }) {
    return LoadingSettingsState(
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      widgetUpdateFrequency:
          widgetUpdateFrequency ?? this.widgetUpdateFrequency,
      dayStartHour: dayStartHour ?? this.dayStartHour,
      nightStartHour: nightStartHour ?? this.nightStartHour,
      debugWeatherProviderOpenWeatherMap:
          debugWeatherProviderOpenWeatherMap ??
          this.debugWeatherProviderOpenWeatherMap,
    );
  }

  @override
  String toString() {
    return 'LoadingSettingsState('
        '  language: $language,'
        '  appVersion: $appVersion,'
        '  widgetUpdateFrequency: $widgetUpdateFrequency,'
        '  dayStartHour: $dayStartHour,'
        '  nightStartHour: $nightStartHour,'
        '  debugWeatherProviderOpenWeatherMap: '
        '$debugWeatherProviderOpenWeatherMap'
        ')';
  }
}

final class SettingsError extends SettingsState {
  const SettingsError({
    required this.errorMessage,
    required super.language,
    super.appVersion,
    super.widgetUpdateFrequency,
    super.dayStartHour,
    super.nightStartHour,
    super.debugWeatherProviderOpenWeatherMap,
  });

  final String errorMessage;

  @override
  SettingsError copyWith({
    String? errorMessage,
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
    int? dayStartHour,
    int? nightStartHour,
    bool? debugWeatherProviderOpenWeatherMap,
  }) {
    return SettingsError(
      errorMessage: errorMessage ?? this.errorMessage,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      widgetUpdateFrequency:
          widgetUpdateFrequency ?? this.widgetUpdateFrequency,
      dayStartHour: dayStartHour ?? this.dayStartHour,
      nightStartHour: nightStartHour ?? this.nightStartHour,
      debugWeatherProviderOpenWeatherMap:
          debugWeatherProviderOpenWeatherMap ??
          this.debugWeatherProviderOpenWeatherMap,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsError &&
        other.errorMessage == errorMessage &&
        other.language == language &&
        other.appVersion == appVersion &&
        other.widgetUpdateFrequency == widgetUpdateFrequency &&
        other.dayStartHour == dayStartHour &&
        other.nightStartHour == nightStartHour &&
        other.debugWeatherProviderOpenWeatherMap ==
            debugWeatherProviderOpenWeatherMap;
  }

  @override
  int get hashCode =>
      errorMessage.hashCode ^
      language.hashCode ^
      appVersion.hashCode ^
      widgetUpdateFrequency.hashCode ^
      dayStartHour.hashCode ^
      nightStartHour.hashCode ^
      debugWeatherProviderOpenWeatherMap.hashCode;

  @override
  String toString() {
    return 'SettingsError('
        '  language: $language,'
        '  appVersion: $appVersion,'
        '  errorMessage: $errorMessage,'
        '  widgetUpdateFrequency: $widgetUpdateFrequency,'
        '  dayStartHour: $dayStartHour,'
        '  nightStartHour: $nightStartHour,'
        '  debugWeatherProviderOpenWeatherMap: '
        '$debugWeatherProviderOpenWeatherMap'
        ')';
  }
}
