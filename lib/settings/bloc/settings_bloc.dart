import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:weather_fit/entities/enums/feedback_rating.dart';
import 'package:weather_fit/entities/enums/feedback_type.dart';
import 'package:weather_fit/res/constants.dart' as constants;

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsInitial()) {
    on<ClosingFeedbackEvent>(_onFeedbackDialogDismissed);
    on<BugReportPressedEvent>(_onFeedbackRequested);
    on<SubmitFeedbackEvent>(_sendUserFeedback);
    on<SettingsErrorEvent>(_handleError);
  }

  FutureOr<void> _handleError(
    SettingsErrorEvent event,
    Emitter<SettingsState> emit,
  ) {
    emit(SettingsError(errorMessage: event.error));
  }

  FutureOr<void> _sendUserFeedback(
    SubmitFeedbackEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const LoadingSettingsState());
    final UserFeedback feedback = event.feedback;
    try {
      final String screenshotFilePath =
          await _writeImageToStorage(feedback.screenshot);

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final Map<String, dynamic>? extra = feedback.extra;
      final dynamic rating = extra?['rating'];
      final dynamic type = extra?['feedback_type'];

      // Construct the feedback text with details from `extra'.
      final StringBuffer feedbackBody = StringBuffer()
        ..writeln('${type is FeedbackType ? 'Feedback Type' : ''}:'
            ' ${type is FeedbackType ? type.value : ''}')
        ..writeln()
        ..writeln(feedback.text)
        ..writeln()
        ..writeln('App id: ${packageInfo.packageName}')
        ..writeln('App version: ${packageInfo.version}')
        ..writeln('Build number: ${packageInfo.buildNumber}')
        ..writeln()
        ..writeln('${rating is FeedbackRating ? 'Rating' : ''}'
            '${rating is FeedbackRating ? ':' : ''}'
            ' ${rating is FeedbackRating ? rating.value : ''}');

      final Email email = Email(
        body: feedbackBody.toString(),
        subject: 'App Feedback: '
            '${packageInfo.appName}',
        recipients: <String>[constants.supportEmail],
        attachmentPaths: <String>[screenshotFilePath],
      );
      try {
        await FlutterEmailSender.send(email);
      } catch (e, stackTrace) {
        debugPrint(
          'Warning: an error occurred in $this: $e;\nStackTrace: $stackTrace',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('SettingsErrorEvent: $e\nStackTrace: $stackTrace');
      add(
        const SettingsErrorEvent(
          'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  FutureOr<void> _onFeedbackRequested(_, Emitter<SettingsState> emit) {
    emit(const FeedbackState());
  }

  Future<String> _writeImageToStorage(Uint8List feedbackScreenshot) async {
    final Directory output = await getTemporaryDirectory();
    final String screenshotFilePath = '${output.path}/feedback.png';
    final File screenshotFile = File(screenshotFilePath);
    await screenshotFile.writeAsBytes(feedbackScreenshot);
    return screenshotFilePath;
  }

  FutureOr<void> _onFeedbackDialogDismissed(_, Emitter<SettingsState> emit) {
    emit(const SettingsInitial());
  }
}
