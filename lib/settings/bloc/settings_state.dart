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
    this.debugForceNight = false,
    this.isWeatherBackgroundEnabled = false,
  });

  final Language language;
  final String? appVersion;
  final int widgetUpdateFrequency;
  final int dayStartHour;
  final int nightStartHour;
  final bool debugWeatherProviderOpenWeatherMap;
  final bool debugForceNight;
  final bool isWeatherBackgroundEnabled;

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
    bool? debugForceNight,
    bool? isWeatherBackgroundEnabled,
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
    super.debugForceNight,
    super.isWeatherBackgroundEnabled,
  });

  @override
  SettingsInitial copyWith({
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
    int? dayStartHour,
    int? nightStartHour,
    bool? debugWeatherProviderOpenWeatherMap,
    bool? debugForceNight,
    bool? isWeatherBackgroundEnabled,
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
      debugForceNight: debugForceNight ?? this.debugForceNight,
      isWeatherBackgroundEnabled:
          isWeatherBackgroundEnabled ?? this.isWeatherBackgroundEnabled,
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
        '$debugWeatherProviderOpenWeatherMap,'
        '  debugForceNight: $debugForceNight,'
        '  isWeatherBackgroundEnabled: $isWeatherBackgroundEnabled'
        '}';
  }
}

final class FeedbackState extends SettingsState {
  const FeedbackState({
    required this.errorMessage,
    required super.language,
    this.query = '',
    super.appVersion,
    super.widgetUpdateFrequency,
    super.dayStartHour,
    super.nightStartHour,
    super.debugWeatherProviderOpenWeatherMap,
    super.debugForceNight,
    super.isWeatherBackgroundEnabled,
  });

  final String errorMessage;
  final String query;

  @override
  String toString() {
    return 'FeedbackState('
        '  errorMessage: $errorMessage,'
        '  query: $query,'
        '  language: $language,'
        '  appVersion: $appVersion,'
        '  widgetUpdateFrequency: $widgetUpdateFrequency,'
        '  dayStartHour: $dayStartHour,'
        '  nightStartHour: $nightStartHour,'
        '  debugWeatherProviderOpenWeatherMap: '
        '$debugWeatherProviderOpenWeatherMap,'
        '  debugForceNight: $debugForceNight,'
        '  isWeatherBackgroundEnabled: $isWeatherBackgroundEnabled'
        ')';
  }

  @override
  FeedbackState copyWith({
    String? errorMessage,
    String? query,
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
    int? dayStartHour,
    int? nightStartHour,
    bool? debugWeatherProviderOpenWeatherMap,
    bool? debugForceNight,
    bool? isWeatherBackgroundEnabled,
  }) {
    return FeedbackState(
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      widgetUpdateFrequency:
          widgetUpdateFrequency ?? this.widgetUpdateFrequency,
      dayStartHour: dayStartHour ?? this.dayStartHour,
      nightStartHour: nightStartHour ?? this.nightStartHour,
      debugWeatherProviderOpenWeatherMap:
          debugWeatherProviderOpenWeatherMap ??
          this.debugWeatherProviderOpenWeatherMap,
      debugForceNight: debugForceNight ?? this.debugForceNight,
      isWeatherBackgroundEnabled:
          isWeatherBackgroundEnabled ?? this.isWeatherBackgroundEnabled,
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
    super.debugForceNight,
    super.isWeatherBackgroundEnabled,
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
        '$debugWeatherProviderOpenWeatherMap,'
        '  debugForceNight: $debugForceNight,'
        '  isWeatherBackgroundEnabled: $isWeatherBackgroundEnabled'
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
    bool? debugForceNight,
    bool? isWeatherBackgroundEnabled,
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
      debugForceNight: debugForceNight ?? this.debugForceNight,
      isWeatherBackgroundEnabled:
          isWeatherBackgroundEnabled ?? this.isWeatherBackgroundEnabled,
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
    super.debugForceNight,
    super.isWeatherBackgroundEnabled,
  });

  @override
  LoadingSettingsState copyWith({
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
    int? dayStartHour,
    int? nightStartHour,
    bool? debugWeatherProviderOpenWeatherMap,
    bool? debugForceNight,
    bool? isWeatherBackgroundEnabled,
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
      debugForceNight: debugForceNight ?? this.debugForceNight,
      isWeatherBackgroundEnabled:
          isWeatherBackgroundEnabled ?? this.isWeatherBackgroundEnabled,
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
        '$debugWeatherProviderOpenWeatherMap,'
        '  debugForceNight: $debugForceNight,'
        '  isWeatherBackgroundEnabled: $isWeatherBackgroundEnabled'
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
    super.debugForceNight,
    super.isWeatherBackgroundEnabled,
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
    bool? debugForceNight,
    bool? isWeatherBackgroundEnabled,
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
      debugForceNight: debugForceNight ?? this.debugForceNight,
      isWeatherBackgroundEnabled:
          isWeatherBackgroundEnabled ?? this.isWeatherBackgroundEnabled,
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
            debugWeatherProviderOpenWeatherMap &&
        other.debugForceNight == debugForceNight &&
        other.isWeatherBackgroundEnabled == isWeatherBackgroundEnabled;
  }

  @override
  int get hashCode =>
      errorMessage.hashCode ^
      language.hashCode ^
      appVersion.hashCode ^
      widgetUpdateFrequency.hashCode ^
      dayStartHour.hashCode ^
      nightStartHour.hashCode ^
      debugWeatherProviderOpenWeatherMap.hashCode ^
      debugForceNight.hashCode ^
      isWeatherBackgroundEnabled.hashCode;

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
        '$debugWeatherProviderOpenWeatherMap,'
        '  debugForceNight: $debugForceNight,'
        '  isWeatherBackgroundEnabled: $isWeatherBackgroundEnabled'
        ')';
  }
}
