import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/res/theme/cubit/theme_cubit.dart';
import 'package:weather_fit/res/widgets/local_web_cors_error.dart';
import 'package:weather_fit/router/app_route.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_fit/weather/ui/outfit_widget.dart';
import 'package:weather_fit/weather/ui/weather.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: <Widget>[
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
          listener: (BuildContext context, WeatherState state) {
            if (state is WeatherSuccess) {
              context.read<ThemeCubit>().updateTheme(state.weather);
              if (state.message.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            }
          },
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
    );
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
}
