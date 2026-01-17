part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {
  const SettingsState({required this.language, this.appVersion});

  final Language language;
  final String? appVersion;

  bool get isEnglish => language == Language.en;

  bool get isUkrainian => language == Language.uk;

  String get locale => language.isoLanguageCode;

  String get languageIsoCode => language.isoLanguageCode;
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial({required super.language, super.appVersion});

  SettingsState copyWith({Language? language, String? appVersion}) {
    return SettingsInitial(
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  String toString() {
    return 'SettingsInitial{'
        '  language: $language,'
        '  appVersion: $appVersion,'
        '}';
  }
}

final class FeedbackState extends SettingsState {
  const FeedbackState({
    required this.errorMessage,
    required super.language,
    super.appVersion,
  });

  final String errorMessage;

  @override
  String toString() => 'FeedbackState()';

  FeedbackState copyWith({
    String? errorMessage,
    Language? language,
    String? appVersion,
  }) {
    return FeedbackState(
      errorMessage: errorMessage ?? this.errorMessage,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

final class FeedbackSent extends SettingsState {
  const FeedbackSent({required super.language, super.appVersion});

  @override
  String toString() => 'FeedbackSent()';

  FeedbackSent copyWith({Language? language, String? appVersion}) {
    return FeedbackSent(
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

final class LoadingSettingsState extends SettingsState {
  const LoadingSettingsState({required super.language, super.appVersion});

  @override
  String toString() => 'LoadingSettingsState()';
}

final class SettingsError extends SettingsState {
  const SettingsError({
    required this.errorMessage,
    required super.language,
    super.appVersion,
  });

  final String errorMessage;

  SettingsError copyWith({
    String? errorMessage,
    Language? language,
    String? appVersion,
  }) {
    return SettingsError(
      errorMessage: errorMessage ?? this.errorMessage,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsError &&
        other.errorMessage == errorMessage &&
        other.language == language &&
        other.appVersion == appVersion;
  }

  @override
  int get hashCode =>
      errorMessage.hashCode ^ language.hashCode ^ appVersion.hashCode;

  @override
  String toString() => 'SettingsError(errorMessage: $errorMessage)';
}
