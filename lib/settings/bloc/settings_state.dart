part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {
  const SettingsState();
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class FeedbackState extends SettingsState {
  const FeedbackState();

  @override
  String toString() => 'FeedbackState()';
}

final class FeedbackSent extends SettingsState {
  const FeedbackSent();

  @override
  String toString() => 'FeedbackSent()';
}

final class LoadingSettingsState extends SettingsState {
  const LoadingSettingsState();

  @override
  String toString() => 'LoadingSettingsState()';
}

final class SettingsError extends SettingsState {
  const SettingsError({required this.errorMessage});

  final String errorMessage;

  SettingsError copyWith({
    String? errorMessage,
  }) =>
      SettingsError(errorMessage: errorMessage ?? this.errorMessage);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsError && other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => errorMessage.hashCode;

  @override
  String toString() => 'ChatError(errorMessage: $errorMessage)';
}
