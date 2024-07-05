part of 'settings_bloc.dart';

@immutable
sealed class SettingsEvent {
  const SettingsEvent();
}

final class BugReportPressedEvent extends SettingsEvent {
  const BugReportPressedEvent();
}

final class SubmitFeedbackEvent extends SettingsEvent {
  const SubmitFeedbackEvent(this.feedback);

  final UserFeedback feedback;
}

final class ClosingFeedbackEvent extends SettingsEvent {
  const ClosingFeedbackEvent();
}

final class ErrorEvent extends SettingsEvent {
  const ErrorEvent(this.error);

  final String error;
}
