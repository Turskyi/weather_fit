import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/extensions/color_extensions.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/res/widgets/store_badge.dart';
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

  /// Called when the user toggles the switch on or off.
  ///
  /// The switch passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the switch with the new
  /// value.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt.
  final ValueChanged<bool> onLanguageChanged;

  final BlocBuilderCondition<WeatherState> rebuildUnitsWhen;

  /// Called when the user toggles the switch on or off.
  ///
  /// The switch passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the switch with the new
  /// value.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt.
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
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: kIsWeb ? const LeadingWidget() : null,
        title: Text(translate('settings.title')),
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
                // Language Switcher Card.
                BlocBuilder<SettingsBloc, SettingsState>(
                  buildWhen: rebuildSettingsWhen,
                  builder: (BuildContext _, SettingsState settingsState) {
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
                                onChanged: onLanguageChanged,
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
                                            .textTheme
                                            .labelSmall
                                            ?.fontSize,
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
                    subtitle: const SizedBox(),
                    trailing: const Icon(Icons.privacy_tip),
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
                      translate('feedback.title'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(translate('settings.feedback_subtitle')),
                    trailing: const Icon(Icons.feedback),
                    onTap: onFeedbackTap,
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
                    onTap: onSupportTap,
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<SettingsBloc, SettingsState>(
                  buildWhen: rebuildSettingsWhen,
                  builder: (BuildContext _, SettingsState settingsState) {
                    final String? version = settingsState.appVersion;
                    if (version == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Text(
                          '${translate('app_version')}: $version',
                          style: themeData.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
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
    );
  }
}
