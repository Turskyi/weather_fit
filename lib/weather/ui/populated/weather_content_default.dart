import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/populated/daily_forecast.dart';
import 'package:weather_fit/weather/ui/weather_icon.dart';

class WeatherContentDefault extends StatelessWidget {
  const WeatherContentDefault({
    required this.weather,
    required this.listenSettingsStateWhen,
    required this.settingsStateListener,
    required this.child,
    required this.onRefresh,
    super.key,
  });

  final Weather weather;
  final BlocListenerCondition<SettingsState> listenSettingsStateWhen;
  final BlocWidgetListener<SettingsState> settingsStateListener;
  final Widget child;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final String countryCode = weather.countryCode.toLowerCase();
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final TextStyle? cityTextStyle = textTheme.displayMedium;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 8),
            if (weather.wasUpdated) WeatherIcon(condition: weather.condition),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (countryCode.isNotEmpty)
                  SvgPicture.network(
                    '${constants.countryFlagsBaseUrl}$countryCode.svg',
                    height: cityTextStyle?.fontSize,
                    errorBuilder: (BuildContext _, Object error, StackTrace _) {
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
                        weather.locationName,
                        style: cityTextStyle?.copyWith(
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (weather.wasUpdated)
              BlocBuilder<WeatherBloc, WeatherState>(
                builder: (BuildContext _, WeatherState state) {
                  return Text(
                    weather.formattedTemperature,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            if (weather.neverUpdated)
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (BuildContext _, SettingsState state) {
                  return Text(
                    weather.getFormattedLastUpdatedDateTime(state.locale),
                  );
                },
              )
            else
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (BuildContext _, SettingsState state) {
                  final String lastUpdatedDateTime = weather
                      .getFormattedLastUpdatedDateTime(state.locale);
                  return Text(
                    '${translate('last_updated_on_label')}\n'
                    '$lastUpdatedDateTime',
                    textAlign: TextAlign.center,
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                weather.translatedWeatherDescription,
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (weather.wasUpdated) child,
            const SizedBox(height: 24),
            BlocBuilder<WeatherBloc, WeatherState>(
              builder: (BuildContext _, WeatherState state) {
                if (state.isNotLoading) {
                  return ElevatedButton(
                    onPressed: onRefresh,
                    child: Text(translate('weather.check_latest_button')),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            const SizedBox(height: 24),

            const DailyForecast(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
