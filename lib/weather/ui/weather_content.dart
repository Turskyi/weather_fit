import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/ui/weather_icon.dart';

import '../bloc/weather_bloc.dart';

class WeatherContent extends StatelessWidget {
  const WeatherContent({
    required this.weather,
    required this.child,
    required this.onRefresh,
    super.key,
  });

  final Weather weather;
  final Widget child;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final TextStyle? cityTextStyle = textTheme.displayMedium;
    final String countryCode = weather.countryCode.toLowerCase();
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 48),
            if (!weather.neverUpdated)
              WeatherIcon(condition: weather.condition),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (countryCode.isNotEmpty)
                  SvgPicture.network(
                    '${constants.countryFlagsBaseUrl}'
                    '$countryCode.svg',
                    height: cityTextStyle?.fontSize,
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    child: Text(
                      weather.locationName,
                      style: cityTextStyle?.copyWith(
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!weather.neverUpdated)
              Text(
                weather.formattedTemperature,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                  return Text(
                    '${translate('last_updated_on_label')} '
                    '${weather.getFormattedLastUpdatedDateTime(
                      state.locale,
                    )}',
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _getTranslatedWeatherDescription(weather.code),
                style: textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            if (!weather.neverUpdated) child,
            const SizedBox(height: 24),
            BlocBuilder<WeatherBloc, WeatherState>(
              builder: (BuildContext _, WeatherState state) {
                if (state is! LoadingOutfitState &&
                    state is! WeatherLoadingState &&
                    weather.needsRefresh) {
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
          ],
        ),
      ),
    );
  }

  String _getTranslatedWeatherDescription(int weatherCode) {
    final String specificKey = 'weather.code_$weatherCode';
    final String fallbackKey = 'weather.code_unknown';

    // Attempt to translate the specific key.
    String translatedDescription = translate(specificKey);

    // If flutter_translate returns the key itself, it means the key was not
    // found.
    // So, we use the fallback translation.
    if (translatedDescription == specificKey) {
      translatedDescription = translate(fallbackKey);
    }

    return translatedDescription;
  }
}
