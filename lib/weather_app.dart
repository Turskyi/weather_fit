import 'dart:typed_data';

import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nested/nested.dart';
import 'package:resend/resend.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/feedback_submission_type.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/env/env.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/resources.dart';
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/router/routes.dart' as routes;
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/services/home_widget_service.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({
    required this.weatherRepository,
    required this.locationRepository,
    required this.outfitRepository,
    required this.localDataSource,
    required this.initialLanguage,
    super.key,
  });

  final WeatherRepository weatherRepository;
  final LocationRepository locationRepository;
  final OutfitRepository outfitRepository;
  final LocalDataSource localDataSource;
  final Language initialLanguage;

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final GlobalKey _screenshotKey = GlobalKey();
  FeedbackController? _feedbackController;
  bool _isFeedbackControllerInitialized = false;
  bool _isDisposing = false;

  @override
  Widget build(BuildContext context) {
    Resend(apiKey: Env.resendApiKey);
    return MultiRepositoryProvider(
      providers: <SingleChildWidget>[
        RepositoryProvider<WeatherRepository>.value(
          value: widget.weatherRepository,
        ),
        RepositoryProvider<OutfitRepository>.value(
          value: widget.outfitRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: <SingleChildWidget>[
          // Provide the theme cubit.
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          BlocProvider<WeatherBloc>(
            create: (BuildContext _) {
              return WeatherBloc(
                widget.weatherRepository,
                widget.outfitRepository,
                widget.localDataSource,
                const HomeWidgetServiceImpl(),
                widget.initialLanguage.isoLanguageCode,
              );
            },
          ),
          BlocProvider<SettingsBloc>(
            create: (BuildContext _) {
              return SettingsBloc(
                widget.localDataSource,
                widget.initialLanguage,
              );
            },
          ),
          BlocProvider<SearchBloc>(
            create: (BuildContext _) {
              return SearchBloc(
                widget.weatherRepository,
                widget.locationRepository,
                widget.localDataSource,
              );
            },
          ),
        ],
        child: BlocBuilder<ThemeCubit, Color>(
          builder: (BuildContext _, Color color) {
            final DateTime now = DateTime.now();
            final int hour = now.hour;
            // Assume darkness from 10 PM to 6 AM
            final bool completeDarkness = hour < 6 || hour > 21;

            return Resources(
              child: BlocListener<SettingsBloc, SettingsState>(
                listener: _settingsBlocStateListener,
                child: RepaintBoundary(
                  key: _screenshotKey,
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: constants.appName,
                    initialRoute: AppRoute.weather.path,
                    routes: routes.getRouteMap(
                      widget.initialLanguage.isoLanguageCode,
                    ),
                    theme: ThemeData(
                      appBarTheme: const AppBarTheme(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      colorScheme: ColorScheme.fromSeed(seedColor: color),
                      textTheme: GoogleFonts.montserratTextTheme(),
                      // FIXME: This font is probably not needed, I added it to
                      //  avoid a "Could not find a set of Noto fonts to
                      //  display all missing characters" error, but it still
                      //  did not help.
                      fontFamily: 'NotoSans',
                    ),
                    darkTheme: ThemeData(
                      appBarTheme: const AppBarTheme(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: color,
                        brightness: Brightness.dark,
                      ),
                      textTheme: GoogleFonts.montserratTextTheme(
                        ThemeData.dark().textTheme,
                      ),
                      fontFamily: 'NotoSans',
                    ),
                    themeMode: completeDarkness
                        ? ThemeMode.dark
                        : ThemeMode.light,
                  ),
                ),
              ),
            );
          },
        ),
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
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
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
        if (Navigator.of(context).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    }
  }

  void _showFeedbackSendingLoadingDialog() {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final double loadingSize = 32.0;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
  }

  /// Captures a screenshot of the widget wrapped with
  /// `_watchFeedbackScreenshotKey`.
  Future<Uint8List> _captureWidgetScreenshot() async {
    // FIXME: There is an issue with screenshot https://github.com/flutter/flutter/issues/22308.
    // Even though there is a workaround we still cannot send this screenshot
    // via resend, so I will return empty Uint8List for now.
    return Future<Uint8List>.value(Uint8List(0));
  }

  void _notifyFeedbackSent() {
    _feedbackController?.hide();
    // Let user know that his feedback is sent.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate('feedback.sent')),
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
