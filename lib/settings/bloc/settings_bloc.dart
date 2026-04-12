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
import 'package:weather_fit/entities/enums/feedback_submission_type.dart';
import 'package:weather_fit/entities/enums/feedback_type.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/entities/models/exceptions/email_launch_exception.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;
import 'package:weather_fit/services/feedback_service.dart';
import 'package:weather_fit/services/update_service.dart';
import 'package:weather_repository/weather_repository.dart';
import 'package:workmanager/workmanager.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(
    this._localDataSource,
    this._updateService,
    this._feedbackService,
  ) : super(
        SettingsInitial(
          language: _localDataSource.getSavedLanguage(),
          widgetUpdateFrequency: _localDataSource.getWidgetUpdateFrequency(),
          dayStartHour: _localDataSource.getDayStartHour(),
          nightStartHour: _localDataSource.getNightStartHour(),
          debugWeatherProviderOpenWeatherMap: _localDataSource
              .getDebugWeatherProviderOpenWeatherMap(),
        ),
      ) {
    on<LoadSettingsEvent>(_onLoadSettings);

    on<CheckForUpdateEvent>(_onCheckForUpdate);

    on<ClosingFeedbackEvent>(_onFeedbackDialogDismissed);

    on<BugReportPressedEvent>(_onFeedbackRequested);

    on<SubmitFeedbackEvent>(_sendUserFeedback);

    on<SettingsErrorEvent>(_handleError);

    on<ChangeLanguageEvent>(_changeLanguage);

    on<ChangeWidgetUpdateFrequencyEvent>(_onChangeWidgetUpdateFrequency);

    on<ChangeDayStartHourEvent>(_onChangeDayStartHour);

    on<ChangeNightStartHourEvent>(_onChangeNightStartHour);

    on<ToggleDebugWeatherProviderEvent>(_onToggleDebugWeatherProvider);

    _applyDayNightConfiguration(
      dayStartHour: state.dayStartHour,
      nightStartHour: state.nightStartHour,
    );

    add(const LoadSettingsEvent());
    add(const CheckForUpdateEvent());
  }

  final LocalDataSource _localDataSource;
  final UpdateService _updateService;
  final FeedbackService _feedbackService;

  FutureOr<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      emit(
        SettingsInitial(
          language: state.language,
          appVersion: '${packageInfo.version} (${packageInfo.buildNumber})',
          widgetUpdateFrequency: _localDataSource.getWidgetUpdateFrequency(),
          dayStartHour: _localDataSource.getDayStartHour(),
          nightStartHour: _localDataSource.getNightStartHour(),
        ),
      );
      _applyDayNightConfiguration(
        dayStartHour: state.dayStartHour,
        nightStartHour: state.nightStartHour,
      );
    } catch (e, stackTrace) {
      debugPrint('SettingsErrorEvent:$e\nStackTrace: $stackTrace');
    }
  }

  FutureOr<void> _onCheckForUpdate(
    CheckForUpdateEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _updateService.checkForUpdate();
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  FutureOr<void> _handleError(
    SettingsErrorEvent event,
    Emitter<SettingsState> emit,
  ) {
    emit(
      SettingsError(
        errorMessage: event.error,
        language: state.language,
        appVersion: state.appVersion,
        widgetUpdateFrequency: state.widgetUpdateFrequency,
        dayStartHour: state.dayStartHour,
        nightStartHour: state.nightStartHour,
      ),
    );
  }

  FutureOr<void> _sendUserFeedback(
    SubmitFeedbackEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! LoadingSettingsState && state is! FeedbackSent) {
      emit(
        LoadingSettingsState(
          language: state.language,
          appVersion: state.appVersion,
          widgetUpdateFrequency: state.widgetUpdateFrequency,
          dayStartHour: state.dayStartHour,
          nightStartHour: state.nightStartHour,
        ),
      );
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
        final Object? rating = extra?[constants.kRatingProperty];
        final Object? type = extra?[constants.kFeedbackTypeProperty];
        final Object? screenSize = extra?[constants.kScreenSizeProperty];
        final String feedbackText = feedback.text;

        // `extra?[constants.feedbackTextProperty]` is usually same as
        // `feedback.text`.
        final Object feedbackExtraText =
            extra?[constants.kFeedbackTextProperty] ?? feedbackText;

        final bool isFeedbackType = type is FeedbackType;
        final bool isFeedbackRating = rating is FeedbackRating;

        // Construct the feedback text with details from `extra'.
        final StringBuffer feedbackBody = StringBuffer()
          ..writeln(
            '${isFeedbackType ? translate('feedback.type') : ''}:'
            ' ${isFeedbackType ? type.value : ''}',
          )
          ..writeln(feedbackText.isEmpty ? feedbackExtraText : feedbackText)
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
          ..writeln()
          ..writeln('${translate('settings.language')}: ${state.language}')
          ..writeln()
          ..writeln('${translate('state')}: $state')
          ..write(
            screenSize == null
                ? ''
                : '${translate('screen_size')}: $screenSize\n',
          );

        if (event.submissionType.isAutomatic) {
          await _feedbackService.sendAutomaticFeedback(
            subject:
                '${translate('feedback.app_feedback')}: ${packageInfo.appName}',
            text: feedbackBody.toString(),
          );
        } else if (kIsWeb || Platform.isMacOS) {
          final Uri emailLaunchUri = Uri(
            scheme: constants.kMailToScheme,
            path: constants.kSupportEmail,
            queryParameters: <String, Object?>{
              constants.kSubjectParameter:
                  '${translate('feedback.app_feedback')}: '
                  '${packageInfo.appName}',
              constants.kBodyParameter: feedbackBody.toString(),
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

            final String errorMessage = translate('error.launch_email_failed');
            emit(
              SettingsError(
                errorMessage: errorMessage,
                language: state.language,
                appVersion: state.appVersion,
                widgetUpdateFrequency: state.widgetUpdateFrequency,
                dayStartHour: state.dayStartHour,
                nightStartHour: state.nightStartHour,
              ),
            );
          }
        } else {
          final String screenshotFilePath = await _writeImageToStorage(
            feedback.screenshot,
          );
          final Email email = Email(
            subject:
                '${translate('feedback.app_feedback')}: ${packageInfo.appName}',
            body: feedbackBody.toString(),
            recipients: <String>[constants.kSupportEmail],
            attachmentPaths: <String>[screenshotFilePath],
          );
          try {
            await FlutterEmailSender.send(email);
          } catch (e, stackTrace) {
            debugPrint(
              'Warning: an error occurred in $this: $e;\n'
              'StackTrace: $stackTrace',
            );
          }
        }

        emit(
          FeedbackSent(
            language: state.language,
            appVersion: state.appVersion,
            widgetUpdateFrequency: state.widgetUpdateFrequency,
            dayStartHour: state.dayStartHour,
            nightStartHour: state.nightStartHour,
          ),
        );
      } catch (e, stackTrace) {
        debugPrint('SettingsErrorEvent:$e\nStackTrace: $stackTrace');
        emit(
          SettingsError(
            errorMessage: translate('error.unexpected_error'),
            language: state.language,
            appVersion: state.appVersion,
            widgetUpdateFrequency: state.widgetUpdateFrequency,
            dayStartHour: state.dayStartHour,
            nightStartHour: state.nightStartHour,
          ),
        );
      }
    }
  }

  FutureOr<void> _onFeedbackRequested(
    BugReportPressedEvent event,
    Emitter<SettingsState> emit,
  ) {
    String errorMessage = event.errorText;

    final SettingsState state = this.state;
    if (state is SettingsError) {
      errorMessage = state.errorMessage;
    } else if (state is FeedbackState) {
      errorMessage = state.errorMessage;
    }
    emit(
      FeedbackState(
        language: state.language,
        errorMessage: errorMessage,
        appVersion: state.appVersion,
        widgetUpdateFrequency: state.widgetUpdateFrequency,
        dayStartHour: state.dayStartHour,
        nightStartHour: state.nightStartHour,
      ),
    );
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
    emit(
      SettingsInitial(
        language: state.language,
        appVersion: state.appVersion,
        widgetUpdateFrequency: state.widgetUpdateFrequency,
        dayStartHour: state.dayStartHour,
        nightStartHour: state.nightStartHour,
      ),
    );
  }

  FutureOr<void> _changeLanguage(
    ChangeLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final Language language = event.language;

    final SettingsState state = this.state;

    if (language != state.language) {
      final bool isSaved = await _localDataSource.saveLanguageIsoCode(
        language.isoLanguageCode,
      );
      if (isSaved) {
        if (state is SettingsInitial) {
          emit(state.copyWith(language: language));
        } else {
          emit(
            SettingsInitial(
              language: language,
              appVersion: state.appVersion,
              widgetUpdateFrequency: state.widgetUpdateFrequency,
              dayStartHour: state.dayStartHour,
              nightStartHour: state.nightStartHour,
            ),
          );
        }
      } else {
        debugPrint(
          'Failed to save language preference: ${language.isoLanguageCode}',
        );
        emit(
          SettingsError(
            errorMessage: translate('error.unexpected_error'),
            language: state.language,
            appVersion: state.appVersion,
            widgetUpdateFrequency: state.widgetUpdateFrequency,
            dayStartHour: state.dayStartHour,
            nightStartHour: state.nightStartHour,
          ),
        );
      }
    }
  }

  FutureOr<void> _onChangeWidgetUpdateFrequency(
    ChangeWidgetUpdateFrequencyEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final int minutes = event.minutes;
    final bool isSaved = await _localDataSource.saveWidgetUpdateFrequency(
      minutes,
    );
    if (isSaved) {
      if (!kIsWeb &&
          !Platform.isMacOS &&
          (Platform.isAndroid || Platform.isIOS)) {
        try {
          await Workmanager().registerPeriodicTask(
            constants.kBackgroundUniqueName,
            constants.kBackgroundTaskName,
            frequency: Duration(minutes: minutes),
            constraints: Constraints(networkType: NetworkType.connected),
            existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
          );
        } catch (e) {
          debugPrint('Failed to re-register Workmanager task: $e');
        }
      }
      emit(state.copyWith(widgetUpdateFrequency: minutes));
    } else {
      emit(
        SettingsError(
          errorMessage: translate('error.unexpected_error'),
          language: state.language,
          appVersion: state.appVersion,
          widgetUpdateFrequency: state.widgetUpdateFrequency,
          dayStartHour: state.dayStartHour,
          nightStartHour: state.nightStartHour,
        ),
      );
    }
  }

  FutureOr<void> _onChangeDayStartHour(
    ChangeDayStartHourEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final int dayStartHour = event.hour;
    final bool isSaved = await _localDataSource.saveDayStartHour(dayStartHour);

    if (isSaved) {
      emit(state.copyWith(dayStartHour: dayStartHour));
      _applyDayNightConfiguration(
        dayStartHour: dayStartHour,
        nightStartHour: state.nightStartHour,
      );
    } else {
      emit(
        SettingsError(
          errorMessage: translate('error.unexpected_error'),
          language: state.language,
          appVersion: state.appVersion,
          widgetUpdateFrequency: state.widgetUpdateFrequency,
          dayStartHour: state.dayStartHour,
          nightStartHour: state.nightStartHour,
        ),
      );
    }
  }

  FutureOr<void> _onChangeNightStartHour(
    ChangeNightStartHourEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final int nightStartHour = event.hour;
    final bool isSaved = await _localDataSource.saveNightStartHour(
      nightStartHour,
    );

    if (isSaved) {
      emit(state.copyWith(nightStartHour: nightStartHour));
      _applyDayNightConfiguration(
        dayStartHour: state.dayStartHour,
        nightStartHour: nightStartHour,
      );
    } else {
      emit(
        SettingsError(
          errorMessage: translate('error.unexpected_error'),
          language: state.language,
          appVersion: state.appVersion,
          widgetUpdateFrequency: state.widgetUpdateFrequency,
          dayStartHour: state.dayStartHour,
          nightStartHour: state.nightStartHour,
        ),
      );
    }
  }

  FutureOr<void> _onToggleDebugWeatherProvider(
    ToggleDebugWeatherProviderEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _localDataSource.setDebugWeatherProviderOpenWeatherMap(event.enabled);
    emit(state.copyWith(debugWeatherProviderOpenWeatherMap: event.enabled));
  }

  void _applyDayNightConfiguration({
    required int dayStartHour,
    required int nightStartHour,
  }) {
    WeatherCondition.configureDayNightHours(
      dayStartHour: dayStartHour,
      nightStartHour: nightStartHour,
    );
  }
}
