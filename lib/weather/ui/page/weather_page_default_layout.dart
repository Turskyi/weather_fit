import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants/constants.dart' as constants;
import 'package:weather_fit/res/widgets/local_web_cors_error.dart';
import 'package:weather_fit/res/widgets/store_badge.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/empty/weather_empty.dart';
import 'package:weather_fit/weather/ui/error/weather_error.dart';
import 'package:weather_fit/weather/ui/populated/weather_populated.dart';
import 'package:weather_fit/weather/ui/widgets/outfit_widget.dart';
import 'package:weather_fit/weather/ui/widgets/weather_loading_widget.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherPageDefaultLayout extends StatelessWidget {
  const WeatherPageDefaultLayout({
    required this.onSettingsPressed,
    required this.onRefresh,
    required this.onSearchPressed,
    required this.onReportPressed,
    this.isEmbedded = false,
    this.location,
    this.bodyOverride,
    super.key,
  });

  /// The callback that is called when the settings button is tapped or
  /// otherwise activated.
  final VoidCallback onSettingsPressed;

  /// A function that's called when the user has dragged the refresh indicator
  /// far enough to demonstrate that they want the app to refresh. The returned
  /// [Future] must complete when the refresh operation is finished.
  final RefreshCallback onRefresh;

  /// The callback that is called when the button is tapped or otherwise
  /// activated.
  final VoidCallback onSearchPressed;

  final VoidCallback onReportPressed;

  final bool isEmbedded;
  final Location? location;
  final Widget? bodyOverride;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Widget content = BlocConsumer<WeatherBloc, WeatherState>(
      listener: _onWeatherStateChanged,
      builder: (BuildContext context, WeatherState state) {
        if (bodyOverride != null) return bodyOverride!;

        if (location != null &&
            location!.isNotEmpty &&
            (state.location.latitude != location!.latitude ||
                state.location.longitude != location!.longitude)) {
          return WeatherPopulated(
            weather: Weather.empty.copyWith(location: location),
            onRefresh: onRefresh,
            child: const WeatherLoadingWidget(),
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
                child: const WeatherLoadingWidget(),
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
              final double screenWidth = MediaQuery.widthOf(context);
              final bool isNarrowScreen = screenWidth < 500;
              final BorderRadius borderRadius = BorderRadius.circular(20.0);

              final Color surfaceColor = colorScheme.surface;
              // Image is still loading
              outfitImageWidget = DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: SizedBox(
                    width: 400,
                    height: isNarrowScreen ? 460 : 400,
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

    final double screenWidth = MediaQuery.widthOf(context);
    final bool isLargeScreen = screenWidth > 800;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onSettingsPressed,
          ),
        ],
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: onSearchPressed,
        child: Icon(Icons.search, semanticLabel: translate('search.label')),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: (kIsWeb && isLargeScreen)
          ? _buildSettingsButtons(context)
          : kIsWeb
          ? <Widget>[
              const StoreBadge(
                url: constants.kGooglePlayUrl,
                assetPath: constants.playStoreBadgePath,
              ),
              const StoreBadge(
                url: constants.kAppStoreUrl,
                assetPath: constants.appStoreBadgeAssetPath,
                height: constants.appStoreBadgeHeight,
                width: constants.appStoreBadgeWidth,
              ),
            ]
          : null,
      persistentFooterDecoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
      ),
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
            duration: const Duration(seconds: 4),
            content: Row(
              children: <Widget>[
                Expanded(child: SelectableText(state.message)),
                TextButton(
                  onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar,
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
  }

  List<Widget> _buildSettingsButtons(BuildContext context) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 8.0, bottom: 8.0, top: 8.0),
        child: ElevatedButton.icon(
          onPressed: onReportPressed,
          icon: const Icon(Icons.feedback),
          label: Text(translate('feedback.title')),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(
            context,
            defaultTargetPlatform == TargetPlatform.android
                ? AppRoute.privacyPolicyAndroid.path
                : AppRoute.privacyPolicy.path,
          ),
          icon: const Icon(Icons.privacy_tip),
          label: Text(translate('privacy_policy')),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoute.about.path),
          icon: const Icon(Icons.info_outline),
          label: Text(translate('about.title')),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoute.support.path),
          icon: const Icon(Icons.support),
          label: Text(translate('support.title')),
        ),
      ),
      const StoreBadge(
        url: constants.kGooglePlayUrl,
        assetPath: constants.playStoreBadgePath,
      ),
      const StoreBadge(
        url: constants.kAppStoreUrl,
        assetPath: constants.appStoreBadgeAssetPath,
        height: constants.appStoreBadgeHeight,
        width: constants.appStoreBadgeWidth,
      ),
    ];
  }
}
