import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/enums/language.dart';
import 'package:weather_fit/res/constants/constants.dart' as constant;
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/res/widgets/wear_position_indicator.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/settings/ui/widgets/blurred_fab_with_border.dart';
import 'package:weather_fit/settings/ui/widgets/setting_dropdown.dart';
import 'package:weather_fit/settings/ui/widgets/setting_segmented_toggle.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class SettingsPageExtraSmallLayout extends StatefulWidget {
  const SettingsPageExtraSmallLayout({
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
    required this.onSearchPressed,
    super.key,
  });

  final BlocBuilderCondition<SettingsState> rebuildSettingsWhen;
  final ValueChanged<Language> onLanguageChanged;
  final ValueChanged<int> onDayStartHourChanged;
  final ValueChanged<int> onNightStartHourChanged;
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
  State<SettingsPageExtraSmallLayout> createState() {
    return _SettingsPageExtraSmallLayoutState();
  }
}

class _SettingsPageExtraSmallLayoutState
    extends State<SettingsPageExtraSmallLayout> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: LeadingWidget(),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: constant.kBlurSigmaSmall,
              sigmaY: constant.kBlurSigmaSmall,
            ),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: WearPositionIndicator(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 60, top: kToolbarHeight),
            children: <Widget>[
              // Language toggle.
              BlocBuilder<SettingsBloc, SettingsState>(
                buildWhen: widget.rebuildSettingsWhen,
                builder: (BuildContext _, SettingsState settingsState) {
                  final int selectedIndex = Language.values.indexOf(
                    settingsState.language,
                  );
                  return SettingSegmentedToggle(
                    label: translate('settings.language'),
                    selectedIndex: selectedIndex,
                    options: Language.values
                        .map((Language l) => translate(l.isoLanguageCode))
                        .toList(),
                    onSelected: (int index) {
                      widget.onLanguageChanged(Language.values[index]);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),

              // Temperature units toggle.
              BlocBuilder<WeatherBloc, WeatherState>(
                buildWhen: widget.rebuildUnitsWhen,
                builder: (BuildContext context, WeatherState state) {
                  final int selectedIndex =
                      state.weather.temperatureUnits.isCelsius ? 0 : 1;
                  return SettingSegmentedToggle(
                    label: translate('settings.temperature_units'),
                    options: const <String>['°C', '°F'],
                    selectedIndex: selectedIndex,
                    onSelected: (int index) {
                      final bool isCelsius = index == 0;
                      widget.onUnitsChanged(isCelsius);
                    }, // true if Celsius
                  );
                },
              ),
              const SizedBox(height: 8),

              // Day/night interval selectors.
              BlocBuilder<SettingsBloc, SettingsState>(
                buildWhen: widget.rebuildSettingsWhen,
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

                  return Column(
                    children: <Widget>[
                      SettingSegmentedToggle(
                        label: translate('settings.weather_background'),
                        selectedIndex: state.isWeatherBackgroundEnabled ? 1 : 0,
                        options: <String>[translate('no'), translate('yes')],
                        onSelected: _onWeatherBackgroundToggled,
                      ),
                      const SizedBox(height: 8),
                      SettingDropdown(
                        label: translate('settings.day_starts'),
                        value: state.dayStartHour,
                        options: dayOptions,
                        onChanged: (int? value) {
                          if (value != null) {
                            widget.onDayStartHourChanged(value);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      SettingDropdown(
                        label: translate('settings.night_starts'),
                        value: state.nightStartHour,
                        options: nightOptions,
                        onChanged: (int? value) {
                          if (value != null) {
                            widget.onNightStartHourChanged(value);
                          }
                        },
                      ),
                      if (kDebugMode) ...<Widget>[
                        const SizedBox(height: 8),
                        SettingSegmentedToggle(
                          label: 'Night Mode (debug)',
                          selectedIndex: state.debugForceNight ? 1 : 0,
                          options: const <String>['Off', 'On'],
                          onSelected: (int index) {
                            context.read<SettingsBloc>().add(
                              ToggleDebugForceNightEvent(index == 1),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        SettingSegmentedToggle(
                          label: 'Force OpenWeatherMap (debug)',
                          selectedIndex:
                              state.debugWeatherProviderOpenWeatherMap ? 1 : 0,
                          options: const <String>['Off', 'On'],
                          onSelected: (int index) {
                            context.read<SettingsBloc>().add(
                              ToggleDebugWeatherProviderEvent(index == 1),
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: BlurredFabWithBorder(
        onPressed: widget.onSearchPressed,
        tooltip: translate('search.label'),
        icon: Icons.search,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _onWeatherBackgroundToggled(int index) {
    return context.read<SettingsBloc>().add(
      ToggleWeatherBackgroundEvent(index == 1),
    );
  }
}
