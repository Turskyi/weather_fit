import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/widgets/local_web_cors_error.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/empty/weather_empty.dart';
import 'package:weather_fit/weather/ui/error/weather_error.dart';
import 'package:weather_fit/weather/ui/populated/weather_populated.dart';
import 'package:weather_fit/weather/ui/widgets/outfit_widget.dart';
import 'package:weather_fit/weather/ui/widgets/weather_loading_widget.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherPageExtraSmallLayout extends StatelessWidget {
  const WeatherPageExtraSmallLayout({
    required this.onSettingsPressed,
    required this.onRefresh,
    required this.onSearchPressed,
    required this.onReportPressed,
    this.weatherStateListener,
    this.isEmbedded = false,
    this.location,
    this.bodyOverride,
    super.key,
  });

  /// The callback that is called when the settings button is tapped or
  /// otherwise activated.
  final VoidCallback onSettingsPressed;

  /// Optional listener for responding to [WeatherState] changes.
  final BlocWidgetListener<WeatherState>? weatherStateListener;

  /// A function that's called when the user has dragged the refresh indicator
  /// far enough to demonstrate that they want the app to refresh. The returned
  /// [Future] must complete when the refresh operation is finished.
  final RefreshCallback onRefresh;

  /// The callback that is called when the "Search" button is tapped or
  /// otherwise activated.
  final VoidCallback onSearchPressed;

  final VoidCallback onReportPressed;

  final bool isEmbedded;
  final Location? location;
  final Widget? bodyOverride;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final Widget content = BlocConsumer<WeatherBloc, WeatherState>(
      listener: _onWeatherStateChanged,
      builder: (BuildContext context, WeatherState state) {
        if (bodyOverride != null) return bodyOverride!;

        if (location != null &&
            location!.isNotEmpty &&
            !state.location.isSamePlaceAs(location!)) {
          return WeatherPopulated(
            weather: Weather.empty.copyWith(location: location),
            onRefresh: onRefresh,
            child: const WeatherLoadingWidget(isShimmer: true),
          );
        }

        final Weather stateWeather = state.weather;
        switch (state) {
          case WeatherInitial():
            return WeatherEmpty(key: key);
          case WeatherLoadingState():
            if (stateWeather.location.isEmpty) {
              return const WeatherLoadingWidget();
            } else {
              return WeatherPopulated(
                weather: stateWeather,
                onRefresh: onRefresh,
                child: const WeatherLoadingWidget(isShimmer: true),
              );
            }
          case WeatherSuccess():
            if (stateWeather.isNoLocation) {
              return const WeatherEmpty();
            }
            Widget outfitImageWidget = const SizedBox();
            final String stateOutfitRecommendation = state.outfitRecommendation;
            if (stateOutfitRecommendation.isNotEmpty) {
              outfitImageWidget = OutfitWidget(
                outfitImage: state.outfitImage,
                outfitRecommendation: stateOutfitRecommendation,
                onRefresh: onRefresh,
              );
            } else if (state is LoadingOutfitState) {
              final BorderRadius borderRadius = BorderRadius.circular(20.0);

              final Color surfaceColor = colorScheme.surface;
              // Image is still loading
              outfitImageWidget = DecoratedBox(
                decoration: BoxDecoration(
                  // Match the ClipRRect's radius.
                  borderRadius: borderRadius,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                      // How far the shadow spreads.
                      spreadRadius: 2,
                      // How blurry the shadow is.
                      blurRadius: 8,
                      // Vertical offset (positive for down).
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: SizedBox(
                    width: 400,
                    height: 460,
                    child: Shimmer.fromColors(
                      baseColor: colorScheme.surfaceContainerHighest,
                      highlightColor: surfaceColor.withValues(alpha: 0.5),
                      child: ColoredBox(color: surfaceColor),
                    ),
                  ),
                ),
              );
            }

            return WeatherPopulated(
              weather: stateWeather,
              onRefresh: onRefresh,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: kIsWeb
                          ? colorScheme.shadow.withValues(alpha: 0.5)
                          : Colors.transparent,
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
                child: outfitImageWidget,
              ),
            );
          case LocalWebCorsFailure():
            if (stateWeather.isNotEmpty) {
              return WeatherPopulated(
                weather: stateWeather,
                onRefresh: onRefresh,
                child: OutfitWidget(
                  outfitImage: state.outfitImage,
                  outfitRecommendation: state.outfitRecommendation,
                  onRefresh: onRefresh,
                ),
              );
            }
            return const LocalWebCorsError();
          case WeatherFailure():
            if (stateWeather.isNotEmpty) {
              return WeatherPopulated(
                weather: stateWeather,
                onRefresh: onRefresh,
                child: OutfitWidget(
                  outfitImage: state.outfitImage,
                  outfitRecommendation: state.outfitRecommendation,
                  onRefresh: onRefresh,
                ),
              );
            }
            return WeatherError(
              message: state.message,
              onReportPressed: onReportPressed,
              onRetryPressed: onRefresh,
            );
        }
      },
    );

    if (isEmbedded) return content;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: cupertino
            .kCupertinoButtonMinSize[cupertino.CupertinoButtonSize.medium],
        centerTitle: true,
        title: IconButton(
          icon: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              Icons.settings,
              color: colorScheme.onSurface,
              size: cupertino.kCupertinoButtonDefaultIconSize,
            ),
          ),
          onPressed: onSettingsPressed,
        ),
      ),
      body: Center(child: content),
      floatingActionButton: (location == null || location!.isEmpty)
          ? FloatingActionButton(
              mini: true,
              onPressed: onSearchPressed,
              child: Icon(
                Icons.search,
                semanticLabel: translate('search.label'),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _onWeatherStateChanged(BuildContext context, WeatherState state) {
    if (!isEmbedded &&
        (state is WeatherFailure || state is LocalWebCorsFailure) &&
        state.weather.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Row(
              children: <Widget>[
                Expanded(child: SelectableText(state.message)),
                TextButton(
                  onPressed: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  child: Text(translate('ok')),
                ),
              ],
            ),
            action: SnackBarAction(
              label: translate('try_again'),
              onPressed: onRefresh,
            ),
          ),
        );
    }
    weatherStateListener?.call(context, state);
  }
}
