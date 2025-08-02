import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/enums/feedback_rating.dart';
import 'package:weather_fit/entities/enums/feedback_type.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/entities/models/exceptions/email_launch_exception.dart';
import 'package:weather_fit/res/constants.dart' as constants;

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._localDataSource, Language initialLanguage)
    : super(SettingsInitial(language: initialLanguage)) {
    on<ClosingFeedbackEvent>(_onFeedbackDialogDismissed);

    on<BugReportPressedEvent>(_onFeedbackRequested);

    on<SubmitFeedbackEvent>(_sendUserFeedback);

    on<SettingsErrorEvent>(_handleError);

    on<ChangeLanguageEvent>(_changeLanguage);
  }

  final LocalDataSource _localDataSource;

  FutureOr<void> _handleError(
    SettingsErrorEvent event,
    Emitter<SettingsState> emit,
  ) {
    emit(SettingsError(errorMessage: event.error, language: state.language));
  }

  FutureOr<void> _sendUserFeedback(
    SubmitFeedbackEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(LoadingSettingsState(language: state.language));
    final UserFeedback feedback = event.feedback;
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final String platform = kIsWeb
          ? translate('web')
          : switch (defaultTargetPlatform) {
              TargetPlatform.android => translate('android'),
              TargetPlatform.iOS => translate('ios'),
              TargetPlatform.macOS => translate('macos'),
              TargetPlatform.windows => translate('windows'),
              TargetPlatform.linux => translate('linux'),
              _ => translate('unknown'),
            };

      final Map<String, Object?>? extra = feedback.extra;
      final Object? rating = extra?[constants.ratingProperty];
      final Object? type = extra?[constants.feedbackTypeProperty];
      // `extra?[constants.feedbackTextProperty]` is usually same as
      // `feedback.text`.
      final Object feedbackText =
          extra?[constants.feedbackTextProperty] ?? feedback.text;

      final bool isFeedbackType = type is FeedbackType;
      final bool isFeedbackRating = rating is FeedbackRating;
      // Construct the feedback text with details from `extra'.
      final StringBuffer feedbackBody = StringBuffer()
        ..writeln(
          '${isFeedbackType ? translate('feedback.type') : ''}:'
          ' ${isFeedbackType ? type.value : ''}',
        )
        ..writeln()
        ..writeln(feedback.text.isEmpty ? feedbackText : '')
        ..writeln()
        ..writeln(
          '${isFeedbackRating ? translate('feedback.rating') : ''}'
          '${isFeedbackRating ? ':' : ''}'
          ' ${isFeedbackRating ? rating.value : ''}',
        )
        ..writeln()
        ..writeln('${translate('app_id')}: ${packageInfo.packageName}')
        ..writeln('${translate('app_version')}: ${packageInfo.version}')
        ..writeln('${translate('build_number')}: ${packageInfo.buildNumber}')
        ..writeln()
        ..writeln('${translate('platform')}: $platform')
        ..writeln();
      if (kIsWeb || Platform.isMacOS) {
        final Uri emailLaunchUri = Uri(
          scheme: constants.mailToScheme,
          path: constants.supportEmail,
          queryParameters: <String, Object?>{
            constants.subjectParameter:
                '${translate('feedback.app_feedback')}:'
                ' ${packageInfo.appName}',
            constants.bodyParameter: feedbackBody.toString(),
          },
        );
        try {
          if (await canLaunchUrl(emailLaunchUri)) {
            await launchUrl(emailLaunchUri);
            debugPrint(
              'Feedback email launched successfully via url_launcher.',
            );
          } else {
            throw const EmailLaunchException('error.launch_email_failed');
          }
        } catch (urlLauncherError, urlLauncherStackTrace) {
          final String urlLauncherErrorMessage =
              'Error launching email via url_launcher: $urlLauncherError';
          debugPrint(
            '$urlLauncherErrorMessage\nStackTrace: $urlLauncherStackTrace',
          );
          // TODO: show an error message to the user.
        }
      } else {
        final String screenshotFilePath = await _writeImageToStorage(
          feedback.screenshot,
        );
        final Email email = Email(
          subject:
              '${translate('feedback.app_feedback')}: ${packageInfo.appName}',
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
      add(SettingsErrorEvent(translate('error.unexpected_error')));
    }
  }

  FutureOr<void> _onFeedbackRequested(
    BugReportPressedEvent _,
    Emitter<SettingsState> emit,
  ) {
    emit(FeedbackState(language: state.language));
  }

  Future<String> _writeImageToStorage(Uint8List feedbackScreenshot) async {
    final Directory output = await getTemporaryDirectory();
    final String screenshotFilePath = '${output.path}/feedback.png';
    final File screenshotFile = File(screenshotFilePath);
    await screenshotFile.writeAsBytes(feedbackScreenshot);
    return screenshotFilePath;
  }

  FutureOr<void> _onFeedbackDialogDismissed(
    ClosingFeedbackEvent _,
    Emitter<SettingsState> emit,
  ) {
    emit(SettingsInitial(language: state.language));
  }

  FutureOr<void> _changeLanguage(
    ChangeLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final Language language = event.language;

    if (language != state.language) {
      final bool isSaved = await _localDataSource.saveLanguageIsoCode(
        language.isoLanguageCode,
      );

      if (isSaved && state is SettingsInitial) {
        emit((state as SettingsInitial).copyWith(language: language));
      } else {
        add(SettingsErrorEvent(translate('error.unexpected_error')));
      }
    }
  }
}
