import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/constants.dart' as constant;
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';

class SettingsPageDefaultLayout extends StatelessWidget {
  const SettingsPageDefaultLayout({
    required this.rebuildSettingsWhen,
    required this.onLanguageChanged,
    required this.rebuildUnitsWhen,
    required this.onUnitsChanged,
    required this.onAboutTap,
    required this.onPrivacyTap,
    required this.onFeedbackTap,
    required this.onSupportTap,
    required this.onPinWidgetTap,
    super.key,
  });

  final BlocBuilderCondition<SettingsState> rebuildSettingsWhen;

  /// Called when the user changes the language.
  final ValueChanged<Language> onLanguageChanged;

  final BlocBuilderCondition<WeatherState> rebuildUnitsWhen;

  /// Called when the user toggles the switch on or off.
  final ValueChanged<bool> onUnitsChanged;

  /// Called when the user taps "About" list tile.
  final GestureTapCallback onAboutTap;

  /// Called when the user taps "Privacy" list tile.
  final GestureTapCallback onPrivacyTap;

  /// Called when the user taps "Feedback" list tile.
  final GestureTapCallback onFeedbackTap;

  /// Called when the user taps "Support" list tile.
  final GestureTapCallback onSupportTap;

  /// Called when the user taps "Pin Widget" list tile.
  final GestureTapCallback onPinWidgetTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: kIsWeb ? const LeadingWidget() : null,
        title: Text(translate('settings.title')),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: constant.blurSigma,
              sigmaY: constant.blurSigma,
            ),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          const Background(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            constraints: BoxConstraints(maxWidth: context.maxWidth),
            child: ListView(
              children: <Widget>[
                // Language Selector Card.
                BlocBuilder<SettingsBloc, SettingsState>(
                  buildWhen: rebuildSettingsWhen,
                  builder: (BuildContext _, SettingsState settingsState) {
                    return Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              translate('settings.language'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<Language>(
                              segments: Language.values.map((
                                Language language,
                              ) {
                                return ButtonSegment<Language>(
                                  value: language,
                                  label: Text(
                                    translate(language.isoLanguageCode),
                                  ),
                                );
                              }).toList(),
                              selected: <Language>{settingsState.language},
                              onSelectionChanged: (Set<Language> newSelection) {
                                onLanguageChanged(newSelection.first);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<WeatherBloc, WeatherState>(
                  buildWhen: rebuildUnitsWhen,
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
                          onChanged: onUnitsChanged,
                        ),
                      ),
                    );
                  },
                ),
                if (!kIsWeb &&
                    (defaultTargetPlatform ==
                        TargetPlatform.android)) ...<Widget>[
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
                        translate('settings.pin_widget'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(translate('settings.pin_widget_subtitle')),
                      trailing: const Icon(Icons.push_pin_outlined),
                      onTap: onPinWidgetTap,
                    ),
                  ),
                ],
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
                    onTap: onAboutTap,
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
                    subtitle: Text(translate('settings.about_app_subtitle')),
                    trailing: const Icon(Icons.privacy_tip_outlined),
                    onTap: onPrivacyTap,
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
                      translate('support_and_feedback'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(translate('settings.support_subtitle')),
                    trailing: const Icon(Icons.help_outline),
                    onTap: onSupportTap,
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
                    trailing: const Icon(Icons.feedback_outlined),
                    onTap: onFeedbackTap,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (BuildContext context, SettingsState state) {
                      return Text(
                        '${translate('app_version')}: ${state.appVersion}',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
