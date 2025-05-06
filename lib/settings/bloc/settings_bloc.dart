import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final String platform = kIsWeb
          ? 'Web'
          : switch (defaultTargetPlatform) {
              TargetPlatform.android => 'Android',
              TargetPlatform.iOS => 'iOS',
              TargetPlatform.macOS => 'macOS',
              TargetPlatform.windows => 'Windows',
              TargetPlatform.linux => 'Linux',
              _ => 'Unknown',
            };

      final Map<String, Object?>? extra = feedback.extra;
      final Object? rating = extra?['rating'];
      final Object? type = extra?['feedback_type'];

      final bool isFeedbackType = type is FeedbackType;
      final bool isFeedbackRating = rating is FeedbackRating;
      // Construct the feedback text with details from `extra'.
      final StringBuffer feedbackBody = StringBuffer()
        ..writeln('${isFeedbackType ? 'Feedback Type' : ''}:'
            ' ${isFeedbackType ? type.value : ''}')
        ..writeln()
        ..writeln(feedback.text)
        ..writeln()
        ..writeln('${isFeedbackRating ? 'Rating' : ''}'
            '${isFeedbackRating ? ':' : ''}'
            ' ${isFeedbackRating ? rating.value : ''}')
        ..writeln()
        ..writeln('App id: ${packageInfo.packageName}')
        ..writeln('App version: ${packageInfo.version}')
        ..writeln('Build number: ${packageInfo.buildNumber}')
        ..writeln()
        ..writeln('Platform: $platform')
        ..writeln();
      if (kIsWeb) {
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: constants.supportEmail,
          queryParameters: <String, Object?>{
            'subject': 'App Feedback: ${packageInfo.appName}',
            'body': feedbackBody.toString(),
          },
        );
        try {
          if (await canLaunchUrl(emailLaunchUri)) {
            await launchUrl(emailLaunchUri);
            debugPrint(
              'Feedback email launched successfully via url_launcher.',
            );
          } else {
            throw 'Could not launch email with url_launcher.';
          }
        } catch (urlLauncherError, urlLauncherStackTrace) {
          final String urlLauncherErrorMessage =
              'Error launching email via url_launcher: $urlLauncherError';
          debugPrint(
            '$urlLauncherErrorMessage\nStackTrace: $urlLauncherStackTrace',
          );
          // Optionally, show an error message to the user.
        }
      } else {
        final String screenshotFilePath = await _writeImageToStorage(
          feedback.screenshot,
        );
        final Email email = Email(
          subject: 'App Feedback: ${packageInfo.appName}',
          body: feedbackBody.toString(),
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
