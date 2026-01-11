import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/res/constants.dart' as constant;
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/settings/ui/blurred_fab_with_border.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';

class SettingsPageExtraSmallLayout extends StatelessWidget {
  const SettingsPageExtraSmallLayout({
    required this.rebuildSettingsWhen,
    required this.onLanguageChanged,
    required this.rebuildUnitsWhen,
    required this.onUnitsChanged,
    required this.onAboutTap,
    required this.onPrivacyTap,
    required this.onFeedbackTap,
    required this.onSupportTap,
    required this.onPinWidgetTap,
    required this.onSearchPressed,
    super.key,
  });

  final BlocBuilderCondition<SettingsState> rebuildSettingsWhen;
  final ValueChanged<bool> onLanguageChanged;
  final BlocBuilderCondition<WeatherState> rebuildUnitsWhen;
  final ValueChanged<bool> onUnitsChanged;
  final GestureTapCallback onAboutTap;
  final GestureTapCallback onPrivacyTap;
  final GestureTapCallback onFeedbackTap;
  final GestureTapCallback onSupportTap;
  final GestureTapCallback onPinWidgetTap;

  /// The callback that is called when the "Search" button is tapped or
  /// otherwise activated.
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: LeadingWidget(),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 60, top: kToolbarHeight),
          children: <Widget>[
            // Language toggle.
            BlocBuilder<SettingsBloc, SettingsState>(
              buildWhen: rebuildSettingsWhen,
              builder: (BuildContext _, SettingsState settingsState) {
                final int selectedIndex = settingsState.isEnglish ? 0 : 1;
                return _SettingSegmentedToggle(
                  label: translate('settings.language'),
                  selectedIndex: selectedIndex,
                  options: <String>[translate('en'), translate('uk')],
                  onSelected: (int index) {
                    final bool isEnglish = index == 0;
                    onLanguageChanged(isEnglish);
                  }, // true if English
                );
              },
            ),
            const SizedBox(height: 8),

            // Temperature units toggle.
            BlocBuilder<WeatherBloc, WeatherState>(
              buildWhen: rebuildUnitsWhen,
              builder: (BuildContext context, WeatherState state) {
                final int selectedIndex =
                    state.weather.temperatureUnits.isCelsius ? 0 : 1;
                return _SettingSegmentedToggle(
                  label: translate('settings.temperature_units'),
                  options: const <String>['°C', '°F'],
                  selectedIndex: selectedIndex,
                  onSelected: (int index) {
                    final bool isCelsius = index == 0;
                    onUnitsChanged(isCelsius);
                  }, // true if Celsius
                );
              },
            ),
            if (!kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.android)) ...<Widget>[
              const SizedBox(height: 16),
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
          ],
        ),
      ),
      floatingActionButton: BlurredFabWithBorder(
        onPressed: onSearchPressed,
        tooltip: translate('search.label'),
        icon: Icons.search,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _SettingSegmentedToggle extends StatelessWidget {
  const _SettingSegmentedToggle({
    required this.label,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorScheme.surfaceContainerHighest,
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List<Widget>.generate(options.length, (int index) {
              final bool isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      options[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
