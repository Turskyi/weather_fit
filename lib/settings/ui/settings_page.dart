import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/settings/ui/google_play_badge.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  FeedbackController? _feedbackController;

  @override
  void didChangeDependencies() {
    _feedbackController = BetterFeedback.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (BuildContext context, SettingsState state) {
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
      },
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
                        'Let us know your thoughts and suggestions.',
                      ),
                      trailing: const Icon(Icons.feedback),
                      onTap: () => context
                          .read<SettingsBloc>()
                          .add(const BugReportPressedEvent()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor:
            Theme.of(context).colorScheme.primaryContainer.brighten(50),
        bottomNavigationBar: kIsWeb
            ? const GooglePlayBadge(
                url:
                    'https://play.google.com/store/apps/details?id=com.turskyi.weather_fit',
                assetPath:
                    'https://play.google.com/intl/en_gb/badges/static/images/badges/en_badge_web_generic.png',
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController?.dispose();
    super.dispose();
  }

  void _notifyFeedbackSent() {
    BetterFeedback.of(context).hide();
    // Let user know that his feedback is sent.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your feedback has been sent successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFeedbackUi() {
    _feedbackController?.show(
      (UserFeedback feedback) =>
          context.read<SettingsBloc>().add(SubmitFeedbackEvent(feedback)),
    );
    _feedbackController?.addListener(_onFeedbackChanged);
  }

  void _onFeedbackChanged() {
    bool? isVisible = _feedbackController?.isVisible;
    if (isVisible == false) {
      _feedbackController?.removeListener(_onFeedbackChanged);
      context.read<SettingsBloc>().add(const ClosingFeedbackEvent());
    }
  }
}
