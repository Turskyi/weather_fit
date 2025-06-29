import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/extensions/color_extensions.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/res/widgets/store_badge.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  FeedbackController? _feedbackController;
  bool _isFeedbackControllerInitialized = false;
  bool _isDisposing = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    return BlocListener<SettingsBloc, SettingsState>(
      listener: _settingsBlocStateListener,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(title: Text(translate('settings.title'))),
        body: Stack(
          children: <Widget>[
            const Background(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                children: <Widget>[
                  // Language Switcher Card.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (SettingsState previous, SettingsState current) {
                      return previous.language != current.language;
                    },
                    builder: (
                      BuildContext _,
                      SettingsState settingsState,
                    ) {
                      final bool isEnglishSelected = settingsState.isEnglish;

                      // Approximate width of the Switch.
                      final double switchWidth = 60.0;
                      // Approximate height of the Switch.
                      final double switchHeight = 38.0;

                      return Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: Text(
                            translate('settings.language'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            // Dynamically show current language.
                            settingsState.isUkrainian
                                ? translate('ukrainian')
                                : translate('english'),
                          ),
                          trailing: SizedBox(
                            width: switchWidth,
                            height: switchHeight,
                            child: Stack(
                              // Align children within the Stack.
                              alignment: Alignment.center,
                              children: <Widget>[
                                // The Switch itself (will be at the bottom of
                                // the stack).
                                Switch(
                                  value: isEnglishSelected,
                                  onChanged: _changeLanguage,
                                ),

                                // Positioned on the left side of the track
                                // area.
                                Positioned(
                                  left: 10.0,
                                  child: AnimatedOpacity(
                                    opacity: isEnglishSelected ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    // Smooth transition
                                    child: IgnorePointer(
                                      // So text doesn't interfere with switch
                                      // tap.
                                      child: Text(
                                        translate('en'),
                                        style: TextStyle(
                                          color: isEnglishSelected
                                              ? colorScheme.onPrimary
                                              : Colors.transparent,
                                          // Text color on active track
                                          fontSize: 10,
                                          // Adjust size
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // "UK" Text - visible when Ukrainian is
                                // selected.
                                // Positioned on the right side of the track
                                // area.
                                Positioned(
                                  right: 12.0,
                                  child: AnimatedOpacity(
                                    opacity: !isEnglishSelected ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: IgnorePointer(
                                      child: Text(
                                        translate('uk'),
                                        style: TextStyle(
                                          color: !isEnglishSelected
                                              ? colorScheme.primary
                                              : Colors.transparent,
                                          fontSize: themeData
                                              .textTheme.labelSmall?.fontSize,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<WeatherBloc, WeatherState>(
                    buildWhen: (WeatherState previous, WeatherState current) =>
                        previous.weather.temperatureUnits !=
                        current.weather.temperatureUnits,
                    builder: (BuildContext context, WeatherState state) {
                      // Determine which subtitle to show
                      final String subtitleKey = state.isCelsius
                          ? 'settings.temperature_units_subtitle_metric'
                          : 'settings.temperature_units_subtitle_imperial';

                      return Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: Text(
                            translate('settings.temperature_units'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(translate(subtitleKey)),
                          trailing: Switch(
                            value: state.weather.temperatureUnits.isCelsius,
                            onChanged: (bool _) => context
                                .read<WeatherBloc>()
                                .add(const ToggleUnits()),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      title: Text(
                        translate('about.title'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(translate('settings.about_app_subtitle')),
                      trailing: const Icon(Icons.info_outline),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoute.about.path,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      title: Text(
                        translate('privacy_policy'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const SizedBox(),
                      trailing: const Icon(Icons.privacy_tip),
                      onTap: () => Navigator.pushNamed(
                        context,
                        defaultTargetPlatform == TargetPlatform.android
                            ? AppRoute.privacyPolicyAndroid.path
                            : AppRoute.privacyPolicy.path,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      title: Text(
                        translate('feedback.title'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(translate('settings.feedback_subtitle')),
                      trailing: const Icon(Icons.feedback),
                      onTap: () => context
                          .read<SettingsBloc>()
                          .add(const BugReportPressedEvent()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      title: Text(
                        translate('support.title'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(translate('settings.support_subtitle')),
                      trailing: const Icon(Icons.help_outline),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoute.support.path,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.primaryContainer.brighten(50),
        bottomNavigationBar: kIsWeb
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // Add some spacing between badges.
                spacing: 10,
                children: <Widget>[
                  StoreBadge(
                    url: constants.googlePlayUrl,
                    assetPath: constants.playStoreBadgePath,
                  ),
                  StoreBadge(
                    url: constants.appStoreUrl,
                    assetPath: constants.appStoreBadgeAssetPath,
                    height: constants.appStoreBadgeHeight,
                    width: constants.appStoreBadgeWidth,
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _changeLanguage(bool isEnglish) {
    final Language newLanguage = isEnglish ? Language.en : Language.uk;
    changeLocale(context, newLanguage.isoLanguageCode)
        // The returned value is always `null`.
        .then((Object? _) {
      if (mounted) {
        context.read<SettingsBloc>().add(ChangeLanguageEvent(newLanguage));
      }
    });
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
              SubmitFeedbackEvent(feedback),
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
      context.read<SettingsBloc>().add(
            const ClosingFeedbackEvent(),
          );
    }
  }

  void _settingsBlocStateListener(BuildContext context, SettingsState state) {
    if (state is FeedbackState) {
      _showFeedbackUi();
    } else if (state is FeedbackSent) {
      _notifyFeedbackSent();
    } else if (state is SettingsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
