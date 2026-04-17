import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;
import 'package:weather_fit/res/widgets/wear_position_indicator.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/populated/wear_forecast_section.dart';
import 'package:weather_fit/weather/ui/widgets/weather_icon.dart';

class WeatherContentExtraSmall extends StatefulWidget {
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
  State<WeatherContentExtraSmall> createState() {
    return _WeatherContentExtraSmallState();
  }
}

class _WeatherContentExtraSmallState extends State<WeatherContentExtraSmall> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final Weather weather = widget.weather;
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final Color watchForegroundColor = context.watchForegroundColor;
    final TextStyle? cityTextStyle = textTheme.bodySmall?.copyWith(
      color: watchForegroundColor,
    );
    final Color surfaceColor = theme.colorScheme.surface.withValues(alpha: 0.9);
    final Color iconChipColor = surfaceColor.computeLuminance() > 0.5
        ? theme.colorScheme.onSurface.withValues(alpha: 0.22)
        : surfaceColor;
    final Color temperatureTextColor = surfaceColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
    final String countryCode = weather.countryCode.toLowerCase();
    const double infoBoxSize = 40.0;
    final BorderRadius infoBoxRadius = BorderRadius.circular(14.0);
    final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      context.wearHorizontalPadding,
      math.max(MediaQuery.paddingOf(context).top + 4, 14),
      context.wearHorizontalPadding,
      context.wearBottomPadding + 12,
    );

    return WearPositionIndicator(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        padding: contentPadding,
        child: Column(
          children: <Widget>[
            Center(child: widget.child),
            const SizedBox(height: 10),
            if (weather.wasUpdated)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.wearHorizontalPadding * 0.6,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 132),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _WearInfoChip(
                          size: infoBoxSize,
                          radius: infoBoxRadius,
                          color: iconChipColor,
                          child: WeatherIcon(condition: weather.condition),
                        ),
                        const SizedBox(width: 16),
                        _WearInfoChip(
                          size: infoBoxSize,
                          radius: infoBoxRadius,
                          color: surfaceColor,
                          child: Text(
                            weather.formattedTemperature,
                            style: textTheme.labelMedium?.copyWith(
                              color: temperatureTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (countryCode.isNotEmpty)
                        SvgPicture.network(
                          '${constants.kCountryFlagsBaseUrl}$countryCode.svg',
                          height: cityTextStyle?.fontSize,
                          errorBuilder:
                              (BuildContext _, Object error, StackTrace _) {
                                debugPrint(
                                  'Error in `WeatherContentExtraSmall`:\n'
                                  'Failed to load country flag for country '
                                  'code "$countryCode".\n$error.',
                                );
                                return const SizedBox();
                              },
                        ),
                      if (countryCode.isNotEmpty) const SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: BlocListener<SettingsBloc, SettingsState>(
                            listenWhen: widget.listenSettingsStateWhen,
                            listener: widget.settingsStateListener,
                            child: Text(
                              weather.locationName,
                              textAlign: TextAlign.center,
                              style: cityTextStyle,
                            ),
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
                              color: isFavourite
                                  ? Colors.amber
                                  : watchForegroundColor,
                            );
                          },
                        ),
                        onPressed: () {
                          final LocalDataSource localDataSource = context
                              .read<LocalDataSource>();
                          final bool isFavourite = localDataSource
                              .isFavouriteLocation(weather.location);
                          context.read<WeatherBloc>().add(
                            ToggleFavouriteEvent(weather.location),
                          );
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 24,
                              ),
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
                  const SizedBox(height: 6),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (BuildContext _, SettingsState state) {
                      final String lastUpdatedDateTime = weather
                          .getFormattedLastUpdatedDateTime(state.locale);
                      final String label = weather.neverUpdated
                          ? lastUpdatedDateTime
                          : '${translate('last_updated_on_label')}\n'
                                '$lastUpdatedDateTime';

                      return Text(
                        label,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: watchForegroundColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.translatedWeatherDescription,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: watchForegroundColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const WearForecastSection(),
            BlocBuilder<WeatherBloc, WeatherState>(
              builder: (BuildContext context, WeatherState state) {
                if (state.isNotLoading) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      onPressed: widget.onRefresh,
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _WearInfoChip extends StatelessWidget {
  const _WearInfoChip({
    required this.size,
    required this.radius,
    required this.color,
    required this.child,
  });

  final double size;
  final BorderRadius radius;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: radius),
      child: child,
    );
  }
}
