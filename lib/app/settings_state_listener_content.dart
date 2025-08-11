import 'dart:typed_data';

import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/enums/feedback_submission_type.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/router/navigator.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';

class SettingsStateListenerContent extends StatefulWidget {
  const SettingsStateListenerContent({this.child, super.key});

  final Widget? child;

  @override
  State<SettingsStateListenerContent> createState() {
    return _SettingsStateListenerContentState();
  }
}

class _SettingsStateListenerContentState
    extends State<SettingsStateListenerContent> {
  FeedbackController? _feedbackController;
  bool _isFeedbackControllerInitialized = false;
  bool _isDisposing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: _settingsBlocStateListener,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _isDisposing = true;
    // Immediately remove the listener.
    _feedbackController?.removeListener(_onFeedbackChanged);

    // Dispose the controller right away.
    _feedbackController?.dispose();
    _feedbackController = null;
    _isFeedbackControllerInitialized = false;
    super.dispose();
  }

  void _settingsBlocStateListener(BuildContext context, SettingsState state) {
    if (state is FeedbackState) {
      if (context.isExtraSmallScreen) {
        _sendFeedbackImmediately(state.errorMessage);
      } else {
        _showFeedbackUi();
      }
    } else if (state is LoadingSettingsState) {
      _showFeedbackSendingLoadingDialog();
    } else if (state is FeedbackSent) {
      _notifyFeedbackSent();

      Future<void>.delayed(const Duration(seconds: 1), () {
        // CRITICAL: Use the navigatorKey's context for dialogs/navigation.
        final BuildContext? dialogContext = navigatorKey.currentContext;
        if (dialogContext != null &&
            dialogContext.mounted &&
            Navigator.of(dialogContext).canPop()) {
          Navigator.of(dialogContext).popAndPushNamed(AppRoute.weather.path);
        }
      });
    } else if (state is SettingsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _sendFeedbackImmediately(String errorText) async {
    try {
      final Uint8List screenshot = await _captureWidgetScreenshot();

      final String feedbackText =
          'Smart Watch user report\n'
          'Device: Smart Watch (detected extra small)\n'
          'Error: $errorText\n'
          'Timestamp: ${DateTime.now().toIso8601String()}';

      if (mounted) {
        final UserFeedback feedback = UserFeedback(
          text: feedbackText,
          screenshot: screenshot,
          extra: <String, Object?>{
            constants.screenSizeProperty: MediaQuery.sizeOf(context).toString(),
          },
        );

        context.read<SettingsBloc>().add(
          SubmitFeedbackEvent(
            feedback: feedback,
            submissionType: FeedbackSubmissionType.automatic,
          ),
        );
      }
    } catch (e, stack) {
      debugPrint(
        'Error sending automatic feedback in SettingsPage: $e\n$stack',
      );
      _showTemporaryFailedMessage();
      if (mounted) {
        // CRITICAL: Use the navigatorKey's context for dialogs/navigation.
        final BuildContext? dialogContext = navigatorKey.currentContext;
        if (dialogContext != null &&
            dialogContext.mounted &&
            Navigator.of(dialogContext).canPop()) {
          Navigator.of(dialogContext, rootNavigator: true).pop();
        }
      }
    }
  }

  void _showFeedbackSendingLoadingDialog() {
    // CRITICAL: Use the navigatorKey's context for dialogs/navigation
    final BuildContext? dialogContext = navigatorKey.currentContext;

    if (dialogContext != null) {
      showDialog<void>(
        context: dialogContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final ThemeData theme = Theme.of(context);
          final TextTheme textTheme = theme.textTheme;
          final double loadingSize = 32.0;
          return Dialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: <Widget>[
                  SizedBox(
                    height: loadingSize,
                    width: loadingSize,
                    child: const CircularProgressIndicator(strokeWidth: 3),
                  ),
                  Text(
                    translate('feedback.sending_short'),
                    textAlign: TextAlign.center,
                    style: context.isExtraSmallScreen
                        ? textTheme.bodySmall
                        : textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // TODO: not sure what to do here.
    }
  }

  /// Captures a screenshot of the widget wrapped with
  /// `_watchFeedbackScreenshotKey`.
  Future<Uint8List> _captureWidgetScreenshot() async {
    // FIXME: There is an issue with screenshot
    //  https://github.com/flutter/flutter/issues/22308.
    // Even though there is a workaround we still cannot send this screenshot
    // via resend, so I will return empty Uint8List for now.
    return Future<Uint8List>.value(Uint8List(0));
  }

  void _notifyFeedbackSent() {
    _feedbackController?.hide();
    // Let user know that his feedback is sent.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate('feedback.sent'), textAlign: TextAlign.center),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFeedbackUi() {
    if (_isDisposing) return;
    if (!_isFeedbackControllerInitialized) {
      _feedbackController = BetterFeedback.of(context);
      _isFeedbackControllerInitialized = true;
    }
    if (_feedbackController != null) {
      _feedbackController?.show(
        (UserFeedback feedback) => context.read<SettingsBloc>().add(
          SubmitFeedbackEvent(feedback: feedback),
        ),
      );
      _feedbackController?.addListener(_onFeedbackChanged);
    }
  }

  void _onFeedbackChanged() {
    if (_isDisposing) return;
    final bool? isVisible = _feedbackController?.isVisible;
    if (isVisible == false) {
      _feedbackController?.removeListener(_onFeedbackChanged);
      _feedbackController = null;
      _isFeedbackControllerInitialized = false;
      context.read<SettingsBloc>().add(const ClosingFeedbackEvent());
    }
  }

  void _showTemporaryFailedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          translate('feedback.failed_short'),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
