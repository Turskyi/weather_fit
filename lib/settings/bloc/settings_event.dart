part of 'settings_bloc.dart';

@immutable
sealed class SettingsEvent {
  const SettingsEvent();
}

final class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

final class CheckForUpdateEvent extends SettingsEvent {
  const CheckForUpdateEvent();
}

final class BugReportPressedEvent extends SettingsEvent {
  const BugReportPressedEvent(this.errorText);

  final String errorText;
}

final class SubmitFeedbackEvent extends SettingsEvent {
  const SubmitFeedbackEvent({
    required this.feedback,
    this.submissionType = FeedbackSubmissionType.manual,
  });

  final UserFeedback feedback;
  final FeedbackSubmissionType submissionType;
}

final class ClosingFeedbackEvent extends SettingsEvent {
  const ClosingFeedbackEvent();
}

final class SettingsErrorEvent extends SettingsEvent {
  const SettingsErrorEvent(this.error);

  final String error;
}

class ChangeLanguageEvent extends SettingsEvent {
  const ChangeLanguageEvent(this.language);

  final Language language;
}

class ChangeWidgetUpdateFrequencyEvent extends SettingsEvent {
  const ChangeWidgetUpdateFrequencyEvent(this.minutes);

  final int minutes;
}

class ChangeDayStartHourEvent extends SettingsEvent {
  const ChangeDayStartHourEvent(this.hour);

  final int hour;
}

class ChangeNightStartHourEvent extends SettingsEvent {
  const ChangeNightStartHourEvent(this.hour);

  final int hour;
}
