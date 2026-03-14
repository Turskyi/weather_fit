import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/widgets/weather_icon.dart';

class WeatherContentExtraSmall extends StatelessWidget {
  const WeatherContentExtraSmall({
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
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final TextStyle? cityTextStyle = textTheme.bodySmall;
    final Color surfaceColor = theme.colorScheme.surface.withValues(alpha: 0.7);
    final String countryCode = weather.countryCode.toLowerCase();
    final double infoBoxSize = 48.0;
    final BorderRadius infoBoxRadius = BorderRadius.circular(12.0);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      clipBehavior: Clip.none,
      child: Column(
        children: <Widget>[
          if (weather.wasUpdated)
            Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Padding(padding: const EdgeInsets.only(top: 8.0), child: child),
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
                        child: WeatherIcon(condition: weather.condition),
                      ),
                      Container(
                        width: infoBoxSize,
                        height: infoBoxSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: infoBoxRadius,
                        ),
                        child: Text(
                          weather.formattedTemperature,
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
                  errorBuilder: (BuildContext _, Object error, StackTrace _) {
                    debugPrint(
                      'Error in `WeatherContentExtraSmall`:\n'
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
                    child: Text(weather.locationName, style: cityTextStyle),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: BlocBuilder<WeatherBloc, WeatherState>(
                  builder: (BuildContext context, WeatherState state) {
                    final bool isFavourite = context
                        .read<LocalDataSource>()
                        .isFavouriteLocation(weather.location);
                    return Icon(
                      isFavourite ? Icons.star : Icons.star_border,
                      color: isFavourite ? Colors.amber : null,
                    );
                  },
                ),
                onPressed: () {
                  final LocalDataSource localDataSource = context
                      .read<LocalDataSource>();
                  final bool isFavourite = localDataSource.isFavouriteLocation(
                    weather.location,
                  );
                  context.read<WeatherBloc>().add(
                    ToggleFavouriteEvent(weather.location),
                  );
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavourite
                            ? translate('location_removed')
                            : translate('location_saved'),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          if (weather.neverUpdated)
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (BuildContext _, SettingsState state) {
                return Text(
                  weather.getFormattedLastUpdatedDateTime(state.locale),
                  style: textTheme.bodySmall,
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
                  style: textTheme.bodySmall,
                );
              },
            ),
          Text(
            weather.translatedWeatherDescription,
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          BlocBuilder<WeatherBloc, WeatherState>(
            builder: (BuildContext context, WeatherState state) {
              if (state.isNotLoading) {
                return Padding(
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
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}
