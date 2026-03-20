part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {
  const SettingsState({
    required this.language,
    this.appVersion,
    this.widgetUpdateFrequency = 120,
  });

  final Language language;
  final String? appVersion;
  final int widgetUpdateFrequency;

  bool get isEnglish => language == Language.en;

  bool get isUkrainian => language == Language.uk;

  String get locale => language.isoLanguageCode;

  String get languageIsoCode => language.isoLanguageCode;

  SettingsState copyWith({
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
  });
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial({
    required super.language,
    super.appVersion,
    super.widgetUpdateFrequency,
  });

  @override
  SettingsInitial copyWith({
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
  }) {
    return SettingsInitial(
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      widgetUpdateFrequency:
          widgetUpdateFrequency ?? this.widgetUpdateFrequency,
    );
  }

  @override
  String toString() {
    return 'SettingsInitial{'
        '  language: $language,'
        '  appVersion: $appVersion,'
        '  widgetUpdateFrequency: $widgetUpdateFrequency,'
        '}';
  }
}

final class FeedbackState extends SettingsState {
  const FeedbackState({
    required this.errorMessage,
    required super.language,
    super.appVersion,
    super.widgetUpdateFrequency,
  });

  final String errorMessage;

  @override
  String toString() {
    return 'FeedbackState('
        '  errorMessage: $errorMessage,'
        '  language: $language,'
        '  appVersion: $appVersion,'
        '  widgetUpdateFrequency: $widgetUpdateFrequency,'
        ')';
  }

  @override
  FeedbackState copyWith({
    String? errorMessage,
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
  }) {
    return FeedbackState(
      errorMessage: errorMessage ?? this.errorMessage,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      widgetUpdateFrequency:
          widgetUpdateFrequency ?? this.widgetUpdateFrequency,
    );
  }
}

final class FeedbackSent extends SettingsState {
  const FeedbackSent({
    required super.language,
    super.appVersion,
    super.widgetUpdateFrequency,
  });

  @override
  String toString() {
    return 'FeedbackSent('
        '  language: $language,'
        '  appVersion: $appVersion,'
        '  widgetUpdateFrequency: $widgetUpdateFrequency,'
        ')';
  }

  @override
  FeedbackSent copyWith({
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
  }) {
    return FeedbackSent(
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      widgetUpdateFrequency:
          widgetUpdateFrequency ?? this.widgetUpdateFrequency,
    );
  }
}

final class LoadingSettingsState extends SettingsState {
  const LoadingSettingsState({
    required super.language,
    super.appVersion,
    super.widgetUpdateFrequency,
  });

  @override
  LoadingSettingsState copyWith({
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
  }) {
    return LoadingSettingsState(
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      widgetUpdateFrequency:
          widgetUpdateFrequency ?? this.widgetUpdateFrequency,
    );
  }

  @override
  String toString() {
    return 'LoadingSettingsState('
        '  language: $language,'
        '  appVersion: $appVersion,'
        '  widgetUpdateFrequency: $widgetUpdateFrequency,'
        ')';
  }
}

final class SettingsError extends SettingsState {
  const SettingsError({
    required this.errorMessage,
    required super.language,
    super.appVersion,
    super.widgetUpdateFrequency,
  });

  final String errorMessage;

  @override
  SettingsError copyWith({
    String? errorMessage,
    Language? language,
    String? appVersion,
    int? widgetUpdateFrequency,
  }) {
    return SettingsError(
      errorMessage: errorMessage ?? this.errorMessage,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
      widgetUpdateFrequency:
          widgetUpdateFrequency ?? this.widgetUpdateFrequency,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsError &&
        other.errorMessage == errorMessage &&
        other.language == language &&
        other.appVersion == appVersion &&
        other.widgetUpdateFrequency == widgetUpdateFrequency;
  }

  @override
  int get hashCode =>
      errorMessage.hashCode ^
      language.hashCode ^
      appVersion.hashCode ^
      widgetUpdateFrequency.hashCode;

  @override
  String toString() {
    return 'SettingsError('
        '  language: $language,'
        '  appVersion: $appVersion,'
        '  errorMessage: $errorMessage,'
        '  widgetUpdateFrequency: $widgetUpdateFrequency,'
        ')';
  }
}
