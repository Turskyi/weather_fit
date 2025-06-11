import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return BlocListener<SettingsBloc, SettingsState>(
      listener: _settingsBlocStateListener,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(title: const Text('Settings')),
        body: Stack(
          children: <Widget>[
            const Background(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                children: <Widget>[
                  BlocBuilder<WeatherBloc, WeatherState>(
                    buildWhen: (WeatherState previous, WeatherState current) =>
                        previous.weather.temperatureUnits !=
                        current.weather.temperatureUnits,
                    builder: (BuildContext context, WeatherState state) {
                      return Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: const Text(
                            'Temperature Units',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'Use metric measurements for temperature units.',
                          ),
                          trailing: Switch(
                            value: state.weather.temperatureUnits.isCelsius,
                            onChanged: (_) => context
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
                      title: const Text(
                        'About',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Learn more about ${constants.appName}.',
                      ),
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
                      title: const Text(
                        'Privacy Policy',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                      title: const Text(
                        'Feedback',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Let us know your thoughts and suggestions. You can '
                        'also report any issues with the app’s content.',
                      ),
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
                      title: const Text(
                        'Support',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Visit our support page for help and frequently asked '
                        'questions.',
                      ),
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
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primaryContainer.brighten(50),
        bottomNavigationBar: kIsWeb
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // Add some spacing between badges.
                spacing: 10,
                children: <Widget>[
                  StoreBadge(
                    url: constants.googlePlayUrl,
                    assetPath: '${constants.imagePath}play_store_badge.png',
                  ),
                  StoreBadge(
                    url: constants.appStoreUrl,
                    assetPath:
                        '${constants.imagePath}Download_on_the_App_Store_Badge'
                        '.png',
                    height: 120,
                    width: 200,
                  ),
                ],
              )
            : null,
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

  void _notifyFeedbackSent() {
    _feedbackController?.hide();
    // Let user know that his feedback is sent.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your feedback has been sent successfully!'),
        duration: Duration(seconds: 2),
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
    bool? isVisible = _feedbackController?.isVisible;
    if (isVisible == false) {
      _feedbackController?.removeListener(_onFeedbackChanged);
      _feedbackController = null;
      _isFeedbackControllerInitialized = false;
      context.read<SettingsBloc>().add(const ClosingFeedbackEvent());
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
