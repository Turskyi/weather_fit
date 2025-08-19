import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/weather_icon.dart';

class WeatherContentExtraSmall extends StatelessWidget {
  const WeatherContentExtraSmall({
    required this.listenSettingsStateWhen,
    required this.settingsStateListener,
    required this.child,
    required this.onRefresh,
    super.key,
  });

  final BlocListenerCondition<SettingsState> listenSettingsStateWhen;
  final BlocWidgetListener<SettingsState> settingsStateListener;
  final Widget child;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final TextStyle? cityTextStyle = textTheme.bodySmall;
    final Color surfaceColor = theme.colorScheme.surface.withValues(alpha: 0.7);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      clipBehavior: Clip.none,
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (BuildContext context, WeatherState state) {
          final Weather stateWeather = state.weather;
          final String countryCode = stateWeather.countryCode.toLowerCase();
          final double infoBoxSize = 48.0;
          final BorderRadius infoBoxRadius = BorderRadius.circular(12.0);
          return Column(
            children: <Widget>[
              if (stateWeather.wasUpdated)
                Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: child,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: context.screenHeight / 3,
                        left: 4,
                        right: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: infoBoxSize,
                            height: infoBoxSize,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: infoBoxRadius,
                            ),
                            child: WeatherIcon(
                              condition: stateWeather.condition,
                            ),
                          ),
                          if (stateWeather.wasUpdated)
                            Container(
                              width: infoBoxSize,
                              height: infoBoxSize,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: infoBoxRadius,
                              ),
                              child: Text(
                                stateWeather.formattedTemperature,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (countryCode.isNotEmpty)
                    SvgPicture.network(
                      '${constants.countryFlagsBaseUrl}$countryCode.svg',
                      height: cityTextStyle?.fontSize,
                      errorBuilder:
                          (BuildContext _, Object error, StackTrace _) {
                            debugPrint(
                              'Error in `WeatherContentDefault`:\n'
                              'Failed to load country flag for country code '
                              '"$countryCode".\n$error.',
                            );
                            return const SizedBox();
                          },
                    ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      child: BlocListener<SettingsBloc, SettingsState>(
                        listenWhen: listenSettingsStateWhen,
                        listener: settingsStateListener,
                        child: Text(
                          stateWeather.locationName,
                          style: cityTextStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (stateWeather.neverUpdated)
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (BuildContext _, SettingsState state) {
                    return Text(
                      stateWeather.getFormattedLastUpdatedDateTime(
                        state.locale,
                      ),
                      style: textTheme.bodySmall,
                    );
                  },
                )
              else
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (BuildContext _, SettingsState state) {
                    final String lastUpdatedDateTime = stateWeather
                        .getFormattedLastUpdatedDateTime(state.locale);
                    return Text(
                      '${translate('last_updated_on_label')}\n'
                      '$lastUpdatedDateTime',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall,
                    );
                  },
                ),
              Text(
                stateWeather.translatedWeatherDescription,
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (state.isNotLoading)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    left: 12.0,
                    right: 12.0,
                    bottom: 48.0,
                  ),
                  child: ElevatedButton(
                    onPressed: onRefresh,
                    child: Text(
                      translate('weather.check_latest_button'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
