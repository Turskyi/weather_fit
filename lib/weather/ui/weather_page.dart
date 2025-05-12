import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/constants.dart' as constants;
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/res/widgets/local_web_cors_error.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/settings/ui/store_badge.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/outfit_widget.dart';
import 'package:weather_fit/weather/ui/weather.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  FeedbackController? _feedbackController;
  bool _isFeedbackControllerInitialized = false;
  bool _isDisposing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: <Widget>[
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoute.settings.path,
              ),
            ),
        ],
      ),
      body: Center(
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: _weatherBlocStateListener,
          builder: (BuildContext context, WeatherState state) {
            switch (state) {
              case WeatherInitial():
                return const WeatherEmpty();
              case WeatherLoadingState():
                if (state.weather.location.isEmpty) {
                  return const WeatherLoadingWidget();
                } else {
                  return WeatherPopulated(
                    weather: state.weather,
                    onRefresh: () => _refresh(context),
                    child: const WeatherLoadingWidget(),
                  );
                }
              case WeatherSuccess():
                if (state.weather.isUnknown) {
                  return const WeatherEmpty();
                }
                Widget outfitImageWidget = const SizedBox();

                if (state.outfitRecommendation.isNotEmpty) {
                  outfitImageWidget = OutfitWidget(
                    needsRefresh: state.weather.needsRefresh,
                    filePath: state.outfitFilePath,
                    outfitRecommendation: state.outfitRecommendation,
                    onRefresh: () => _refresh(context),
                  );
                } else if (state is LoadingOutfitState) {
                  final double screenWidth = MediaQuery.sizeOf(context).width;
                  final bool isNarrowScreen = screenWidth < 500;
                  final BorderRadius borderRadius = BorderRadius.circular(20.0);
                  // Image is still loading
                  outfitImageWidget = DecoratedBox(
                    decoration: BoxDecoration(
                      // Match the ClipRRect's radius.
                      borderRadius: borderRadius,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
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
                        height: isNarrowScreen ? 460 : 400,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: const ColoredBox(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }

                return WeatherPopulated(
                  weather: state.weather,
                  onRefresh: () => _refresh(context),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: kIsWeb ? Colors.black54 : Colors.transparent,
                          blurRadius: 10,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: outfitImageWidget,
                  ),
                );
              case LocalWebCorsFailure():
                return const LocalWebCorsError();
              case WeatherFailure():
                return WeatherError(state.message);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleLocationSearchAndFetchWeather(context),
        child: const Icon(Icons.search, semanticLabel: 'Search'),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: kIsWeb ? _buildSettingsButtons(context) : null,
    );
  }

  @override
  void dispose() {
    _isDisposing = true;
    // Immediately remove the listener.
    _feedbackController?.removeListener(_onFeedbackChanged);

    // Dispose the controller right away.
    _feedbackController?.dispose();
    _feedbackController = null;

    super.dispose();
  }

  Future<void> _handleLocationSearchAndFetchWeather(
    BuildContext context,
  ) async {
    final Object? weather = await Navigator.pushNamed<Object>(
      context,
      AppRoute.search.path,
    );

    if (context.mounted && weather is Weather) {
      context.read<WeatherBloc>().add(GetOutfitEvent(weather));
    } else {
      return;
    }
  }

  Future<void> _refresh(BuildContext context) => Future<void>.delayed(
        Duration.zero,
        () {
          if (context.mounted) {
            context.read<WeatherBloc>().add(const RefreshWeather());
          }
        },
      );

  void _weatherBlocStateListener(BuildContext context, WeatherState state) {
    if (state is WeatherSuccess) {
      context.read<ThemeCubit>().updateTheme(state.weather);
      if (state.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    }
  }

  List<Widget> _buildSettingsButtons(BuildContext context) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 8.0, bottom: 8.0, top: 8.0),
        child: BlocListener<SettingsBloc, SettingsState>(
          listener: _settingsBlocStateListener,
          child: ElevatedButton.icon(
            onPressed: () => context.read<SettingsBloc>().add(
                  const BugReportPressedEvent(),
                ),
            icon: const Icon(Icons.feedback),
            label: const Text('Feedback'),
          ),
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
          label: const Text('Privacy Policy'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoute.about.path),
          icon: const Icon(Icons.info_outline),
          label: const Text('About'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoute.support.path),
          icon: const Icon(Icons.support),
          label: const Text('Support'),
        ),
      ),
      const StoreBadge(
        url: constants.googlePlayUrl,
        assetPath: '${constants.imagePath}play_store_badge.png',
        height: 90,
        width: 150,
      ),
      const StoreBadge(
        url: constants.appStoreUrl,
        assetPath: '${constants.imagePath}Download_on_the_App_Store_Badge.png',
        height: 80,
        width: 140,
      ),
    ];
  }

  void _settingsBlocStateListener(BuildContext context, SettingsState state) {
    if (state is FeedbackState) {
      _showFeedbackUi();
    } else if (state is FeedbackSent) {
      _notifyFeedbackSent();
    } else if (state is SettingsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFeedbackUi() {
    if (!_isFeedbackControllerInitialized) {
      _feedbackController = BetterFeedback.of(context);
      _isFeedbackControllerInitialized = true;
    }
    if (_isDisposing) return;
    if (_feedbackController != null) {
      _feedbackController?.show(
        (UserFeedback feedback) => context.read<SettingsBloc>().add(
              SubmitFeedbackEvent(feedback),
            ),
      );
      _feedbackController?.addListener(_onFeedbackChanged);
    }
  }

  void _onFeedbackChanged() {
    if (_isDisposing) return;
    bool? isVisible = _feedbackController?.isVisible;
    if (isVisible == false) {
      _feedbackController?.removeListener(_onFeedbackChanged);
      context.read<SettingsBloc>().add(const ClosingFeedbackEvent());
    }
  }

  void _notifyFeedbackSent() {
    BetterFeedback.of(context).hide();
    // Let user know that his feedback is sent.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your feedback has been sent successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
