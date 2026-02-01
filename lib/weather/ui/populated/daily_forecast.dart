import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

import 'forecast_item_widget.dart';
import 'forecast_outfit_preview.dart';

class DailyForecast extends StatefulWidget {
  const DailyForecast({super.key});

  @override
  State<DailyForecast> createState() => _DailyForecastState();
}

class _DailyForecastState extends State<DailyForecast> {
  OverlayEntry? _overlayEntry;
  OverlayEntry? _backdropEntry;
  int? _visibleIndex;
  final List<GlobalKey> _itemKeys = <GlobalKey>[];

  bool get _isTouchInteraction =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.android;

  void _showPreview({
    required BuildContext context,
    required int index,
    required ForecastItemDomain item,
    required WeatherState state,
  }) {
    // Ensure only one preview is visible.
    _hidePreview();

    final RenderBox? renderBox =
        _itemKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final double itemLeft = offset.dx;
    final double top = offset.dy;

    // Preview card is approximately 156px wide (140 image + 16 padding)
    const double previewWidth = 156.0;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Center the preview on the item
    double left = itemLeft + (size.width / 2) - (previewWidth / 2);

    // Keep preview within screen bounds with 8px padding
    const double screenPadding = 8.0;
    if (left < screenPadding) {
      left = screenPadding;
    } else if (left + previewWidth > screenWidth - screenPadding) {
      left = screenWidth - previewWidth - screenPadding;
    }

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          left: left,
          top: top - (size.height * 0.9),
          child: IgnorePointer(
            ignoring: true,
            child: Material(
              color: Colors.transparent,
              child: ForecastOutfitPreview(
                item: item,
                baseWeather: state.weather,
                isCelsius: state.isCelsius,
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    // On mobile (app or web), add a dismissible backdrop to allow tapping
    // outside to close.
    if (_isTouchInteraction) {
      final OverlayEntry backdropEntry = OverlayEntry(
        builder: (BuildContext context) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _hidePreview,
            child: const ColoredBox(color: Colors.transparent),
          );
        },
      );
      Overlay.of(context).insert(backdropEntry);
      // Store backdrop reference to remove it later.
      _backdropEntry = backdropEntry;
    }

    setState(() {
      _visibleIndex = index;
    });
  }

  void _hidePreview() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _backdropEntry?.remove();
    _backdropEntry = null;
    if (mounted) {
      setState(() {
        _visibleIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BlocBuilder<WeatherBloc, WeatherState>(
                    builder: (BuildContext context, WeatherState state) {
                      final DailyForecastDomain? dailyForecast =
                          state.dailyForecast;
                      if (dailyForecast == null) {
                        return Center(
                          child: Text(translate('weather.loading_forecast')),
                        );
                      }
                      final List<ForecastItemDomain> forecastItems =
                          dailyForecast.forecast;

                      final DateTime now = DateTime.now();
                      const List<int> desiredHours = <int>[8, 13, 19];

                      final List<ForecastItemDomain> forecast = forecastItems
                          .where((ForecastItemDomain item) {
                            final DateTime itemTime = DateTime.parse(item.time);
                            return itemTime.isAfter(now) &&
                                desiredHours.contains(itemTime.hour);
                          })
                          .take(3)
                          .toList();

                      if (forecast.isEmpty) {
                        return Center(
                          child: Text(
                            translate('weather.forecast_unavailable'),
                          ),
                        );
                      }

                      final bool isCelsius = state.isCelsius;

                      // Prepare keys for each item so we can compute positions.
                      _itemKeys.clear();
                      for (int i = 0; i < forecast.length; i++) {
                        _itemKeys.add(GlobalKey());
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          for (int i = 0; i < forecast.length; i++)
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (PointerEnterEvent _) {
                                if (kIsWeb && !_isTouchInteraction) {
                                  _showPreview(
                                    context: context,
                                    index: i,
                                    item: forecast[i],
                                    state: state,
                                  );
                                }
                              },
                              onExit: (PointerExitEvent _) {
                                if (kIsWeb && !_isTouchInteraction) {
                                  _hidePreview();
                                }
                              },
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (_isTouchInteraction) {
                                      if (_visibleIndex == i) {
                                        _hidePreview();
                                      } else {
                                        _showPreview(
                                          context: context,
                                          index: i,
                                          item: forecast[i],
                                          state: state,
                                        );
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    key: _itemKeys[i],
                                    constraints: const BoxConstraints(
                                      minWidth: 90,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: AnimatedScale(
                                      scale: _visibleIndex == i ? 0.98 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      child: ForecastItemWidget(
                                        item: forecast[i],
                                        isCelsius: isCelsius,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
