import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/constants/constants.dart' as constant;
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class SettingsPageDefaultLayout extends StatelessWidget {
  const SettingsPageDefaultLayout({
    required this.rebuildSettingsWhen,
    required this.onLanguageChanged,
    required this.onDayStartHourChanged,
    required this.onNightStartHourChanged,
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

  final ValueChanged<int> onDayStartHourChanged;

  final ValueChanged<int> onNightStartHourChanged;

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
              sigmaX: constant.kBlurSigma,
              sigmaY: constant.kBlurSigma,
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
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
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
                              onSelectionChanged: _onLanguageSelected,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<SettingsBloc, SettingsState>(
                  buildWhen: rebuildSettingsWhen,
                  builder: (BuildContext context, SettingsState state) {
                    final List<int> dayOptions = List<int>.generate(
                      WeatherCondition.maxDayStartHour -
                          WeatherCondition.minDayStartHour +
                          1,
                      (int index) {
                        return WeatherCondition.minDayStartHour + index;
                      },
                    );
                    final List<int> nightOptions = List<int>.generate(
                      WeatherCondition.maxNightStartHour -
                          WeatherCondition.minNightStartHour +
                          1,
                      (int index) {
                        return WeatherCondition.minNightStartHour + index;
                      },
                    );

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
                              translate('settings.day_night_title'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              translate('settings.day_night_subtitle'),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              initialValue: state.dayStartHour,
                              decoration: InputDecoration(
                                labelText: translate('settings.day_starts'),
                              ),
                              items: dayOptions.map((int hour) {
                                return DropdownMenuItem<int>(
                                  value: hour,
                                  child: Text(_formatHourLabel(hour)),
                                );
                              }).toList(),
                              onChanged: (int? value) {
                                if (value != null) {
                                  onDayStartHourChanged(value);
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              initialValue: state.nightStartHour,
                              decoration: InputDecoration(
                                labelText: translate('settings.night_starts'),
                              ),
                              items: nightOptions.map((int hour) {
                                return DropdownMenuItem<int>(
                                  value: hour,
                                  child: Text(_formatHourLabel(hour)),
                                );
                              }).toList(),
                              onChanged: (int? value) {
                                if (value != null) {
                                  onNightStartHourChanged(value);
                                }
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
                if (!kIsWeb && !context.isExtraSmallScreen) ...<Widget>[
                  const SizedBox(height: 20),
                  // Home Widget Updates Card.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: rebuildSettingsWhen,
                    builder: (BuildContext context, SettingsState state) {
                      final bool isAndroid =
                          defaultTargetPlatform == TargetPlatform.android;

                      final Map<int, String> options = isAndroid
                          ? <int, String>{
                              15: translate('settings.frequency_15m'),
                              30: translate('settings.frequency_30m'),
                              60: translate('settings.frequency_1h'),
                              constant.kAndroidDefaultMinutesFrequency:
                                  translate('settings.frequency_2h'),
                              360: translate('settings.frequency_6h'),
                              720: translate('settings.frequency_12h'),
                              1440: translate('settings.frequency_24h'),
                            }
                          : <int, String>{
                              60: translate('settings.frequency_1h'),
                              constant.kIosDefaultMinutesFrequency: translate(
                                'settings.frequency_3h',
                              ),
                              360: translate('settings.frequency_6h'),
                              720: translate('settings.frequency_12h'),
                              1440: translate('settings.frequency_24h'),
                            };

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
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          translate(
                                            'settings.widget_updates_title',
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          translate(
                                            'settings.widget_updates_subtitle',
                                            args: <String, Object?>{
                                              'appName': constant.kAppName,
                                            },
                                          ),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () {
                                      _showWidgetInfoDialog(context);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder:
                                    (
                                      BuildContext context,
                                      BoxConstraints constraints,
                                    ) {
                                      // Use Dropdown if space is limited,
                                      // otherwise SegmentedButton.
                                      if (constraints.maxWidth < 400) {
                                        return DropdownButton<int>(
                                          value: state.widgetUpdateFrequency,
                                          isExpanded: true,
                                          items: options.entries.map((
                                            MapEntry<int, String> entry,
                                          ) {
                                            return DropdownMenuItem<int>(
                                              value: entry.key,
                                              child: Text(entry.value),
                                            );
                                          }).toList(),
                                          onChanged: (int? value) {
                                            _onWidgetUpdateFrequencyChanged(
                                              value: value,
                                              context: context,
                                            );
                                          },
                                        );
                                      }
                                      return SegmentedButton<int>(
                                        segments: options.entries.map((
                                          MapEntry<int, String> entry,
                                        ) {
                                          return ButtonSegment<int>(
                                            value: entry.key,
                                            label: Text(
                                              entry.value,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        selected: <int>{
                                          state.widgetUpdateFrequency,
                                        },
                                        onSelectionChanged: (Set<int> value) {
                                          context.read<SettingsBloc>().add(
                                            ChangeWidgetUpdateFrequencyEvent(
                                              value.first,
                                            ),
                                          );
                                        },
                                      );
                                    },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
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
                const SizedBox(height: 24),
                if (kDebugMode) ...<Widget>[
                  Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (BuildContext context, SettingsState state) {
                        return SwitchListTile(
                          title: const Text('Force Night Mode (debug)'),
                          subtitle: const Text(
                            'Switch "night" and "day" without waiting',
                          ),
                          value: state.debugForceNight,
                          onChanged: (bool value) {
                            context.read<SettingsBloc>().add(
                              ToggleDebugForceNightEvent(value),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (BuildContext context, SettingsState state) {
                        return SwitchListTile(
                          title: const Text('Force OpenWeatherMap (debug)'),
                          subtitle: const Text(
                            'Use OpenWeatherMap as the weather provider '
                            '(fallback)',
                          ),
                          value: state.debugWeatherProviderOpenWeatherMap,
                          onChanged: (bool value) {
                            context.read<SettingsBloc>().add(
                              ToggleDebugWeatherProviderEvent(value),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onWidgetUpdateFrequencyChanged({
    required BuildContext context,
    required int? value,
  }) {
    if (value != null) {
      context.read<SettingsBloc>().add(ChangeWidgetUpdateFrequencyEvent(value));
    }
  }

  void _onLanguageSelected(Set<Language> newSelection) {
    final Language? language = newSelection.firstOrNull;
    if (language != null) {
      onLanguageChanged(language);
    }
  }

  String _formatHourLabel(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  Future<void> _showWidgetInfoDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;

        return AlertDialog(
          title: Text(
            isAndroid
                ? translate('settings.widget_info_title_android')
                : translate('settings.widget_info_title_ios'),
          ),
          content: Text(
            isAndroid
                ? translate('settings.widget_info_content_android')
                : translate('settings.widget_info_content_ios'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(translate('settings.ok')),
            ),
          ],
        );
      },
    );
  }
}
