import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/widgets/local_web_cors_error.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/empty/weather_empty.dart';
import 'package:weather_fit/weather/ui/error/weather_error.dart';
import 'package:weather_fit/weather/ui/populated/weather_populated.dart';
import 'package:weather_fit/weather/ui/widgets/outfit_widget.dart';
import 'package:weather_fit/weather/ui/widgets/weather_loading_widget.dart';
import 'package:weather_repository/weather_repository.dart';

DateTime? _lastExtraSmallShimmerLogAt;
String? _lastExtraSmallShimmerLogKey;

void _logExtraSmallShimmerReason({
  required String reason,
  required WeatherState state,
  Location? pageLocation,
}) {
  if (!kDebugMode) {
    return;
  } else {
    final String key =
        '$reason|${state.runtimeType}|${state.location}|$pageLocation';
    final DateTime now = DateTime.now();
    final bool shouldSkipLog =
        _lastExtraSmallShimmerLogKey == key &&
        _lastExtraSmallShimmerLogAt != null &&
        now.difference(_lastExtraSmallShimmerLogAt!) <
            const Duration(seconds: 2);

    if (shouldSkipLog) {
      return;
    } else {
      _lastExtraSmallShimmerLogAt = now;
      _lastExtraSmallShimmerLogKey = key;
      debugPrint(
        'WeatherPageExtraSmall shimmer: reason=$reason, '
        'state=${state.runtimeType}, stateLocation=${state.location}, '
        'pageLocation=$pageLocation.',
      );
    }
  }
}

class WeatherPageExtraSmallLayout extends StatefulWidget {
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
  State<WeatherPageExtraSmallLayout> createState() =>
      _WeatherPageExtraSmallLayoutState();
}

class _WeatherPageExtraSmallLayoutState
    extends State<WeatherPageExtraSmallLayout> {
  static const Size _wearableOutfitPlaceholderSize = Size(148, 194);
  bool _isAtScrollBottom = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool showSearchFab = context.select<WeatherBloc, bool>((
      WeatherBloc bloc,
    ) {
      final WeatherState state = bloc.state;
      return state is WeatherInitial ||
          (state is WeatherSuccess && state.weather.isNoLocation);
    });

    final Widget content = BlocConsumer<WeatherBloc, WeatherState>(
      listener: _onWeatherStateChanged,
      builder: (BuildContext context, WeatherState state) {
        if (widget.bodyOverride != null) return widget.bodyOverride!;

        if (widget.location != null &&
            widget.location!.isNotEmpty &&
            !state.location.isSamePlaceAs(widget.location!)) {
          _logExtraSmallShimmerReason(
            reason: 'location_mismatch',
            state: state,
            pageLocation: widget.location,
          );
          return WeatherPopulated(
            weather: Weather.empty.copyWith(location: widget.location),
            onRefresh: widget.onRefresh,
            child: const WeatherLoadingWidget(isShimmer: true),
          );
        }

        final Weather stateWeather = state.weather;
        switch (state) {
          case WeatherInitial():
            return WeatherEmpty(key: widget.key);
          case WeatherLoadingState():
            if (stateWeather.location.isEmpty) {
              return const WeatherLoadingWidget();
            } else {
              _logExtraSmallShimmerReason(
                reason: 'weather_loading_state',
                state: state,
                pageLocation: widget.location,
              );
              return WeatherPopulated(
                weather: stateWeather,
                onRefresh: widget.onRefresh,
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
                onRefresh: widget.onRefresh,
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
                    width: _wearableOutfitPlaceholderSize.width,
                    height: _wearableOutfitPlaceholderSize.height,
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
              onRefresh: widget.onRefresh,
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
                onRefresh: widget.onRefresh,
                child: OutfitWidget(
                  outfitImage: state.outfitImage,
                  outfitRecommendation: state.outfitRecommendation,
                  onRefresh: widget.onRefresh,
                ),
              );
            }
            return const LocalWebCorsError();
          case WeatherFailure():
            if (stateWeather.isNotEmpty) {
              return WeatherPopulated(
                weather: stateWeather,
                onRefresh: widget.onRefresh,
                child: OutfitWidget(
                  outfitImage: state.outfitImage,
                  outfitRecommendation: state.outfitRecommendation,
                  onRefresh: widget.onRefresh,
                ),
              );
            }
            return WeatherError(
              message: state.message,
              onReportPressed: widget.onReportPressed,
              onRetryPressed: widget.onRefresh,
            );
        }
      },
    );

    if (widget.isEmbedded) return content;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: cupertino
            .kCupertinoButtonMinSize[cupertino.CupertinoButtonSize.medium],
        forceMaterialTransparency: true,
        title: Tooltip(
          message: translate('settings.title'),
          child: Material(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: SizedBox.square(
              dimension: 30.0,
              child: InkResponse(
                onTap: widget.onSettingsPressed,
                containedInkWell: true,
                customBorder: const CircleBorder(),
                highlightShape: BoxShape.circle,
                radius: 8,
                splashColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                highlightColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.05,
                ),
                child: Icon(
                  Icons.settings,
                  color: colorScheme.surface,
                  size: cupertino.kCupertinoButtonDefaultIconSize,
                ),
              ),
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: ColoredBox(
          color: Colors.black,
          child: Center(child: content),
        ),
      ),
      floatingActionButton: showSearchFab || _isAtScrollBottom
          ? FloatingActionButton.small(
              onPressed: widget.onSearchPressed,
              tooltip: translate('search.label'),
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
    if (!widget.isEmbedded &&
        (state is WeatherFailure || state is LocalWebCorsFailure) &&
        state.weather.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: const StadiumBorder(),
            margin: EdgeInsets.fromLTRB(
              28,
              0,
              28,
              context.wearBottomPadding + 8,
            ),
            duration: const Duration(seconds: 3),
            content: Text(state.message, textAlign: TextAlign.center),
            action: SnackBarAction(
              label: translate('try_again'),
              onPressed: widget.onRefresh,
            ),
          ),
        );
    }
    widget.weatherStateListener?.call(context, state);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    final bool isAtBottom =
        notification.metrics.atEdge && notification.metrics.pixels > 0;
    // Guard against redundant state updates and use `postFrameCallback` to
    // avoid "Build scheduled during frame" errors if setState is triggered
    // during layout.
    if (isAtBottom != _isAtScrollBottom) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          setState(() {
            _isAtScrollBottom = isAtBottom;
          });
        }
      });
    }
    return false;
  }
}
