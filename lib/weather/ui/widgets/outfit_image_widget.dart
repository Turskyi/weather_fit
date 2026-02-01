import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_fit/entities/enums/outfit_image_source.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/weather/ui/error/outfit_image_error_widget.dart';

class OutfitImageWidget extends StatefulWidget {
  const OutfitImageWidget({
    required this.outfitImage,
    required this.onRefresh,
    this.fit = BoxFit.fitHeight,
    super.key,
  });

  final OutfitImage outfitImage;
  final RefreshCallback onRefresh;
  final BoxFit fit;

  @override
  State<OutfitImageWidget> createState() => _OutfitImageWidgetState();
}

class _OutfitImageWidgetState extends State<OutfitImageWidget> {
  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<String> paths = widget.outfitImage.paths;

    return Container(
      color: colorScheme.surface,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(
        left: 8.0,
        top: 8.0,
        bottom: 8.0,
        right: 4.0,
      ),
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            clipBehavior: Clip.antiAlias,
            child: ScrollConfiguration(
              behavior: const _MouseDragScrollBehavior(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: paths.length,
                onPageChanged: (int index) {
                  setState(() {
                    _pageIndex = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return _OutfitImageItem(
                    path: paths[index],
                    source: widget.outfitImage.source,
                    fit: widget.fit,
                    onRefresh: widget.onRefresh,
                  );
                },
              ),
            ),
          ),
          if (paths.length > 1)
            Positioned(
              bottom: 12.0,
              left: 0.0,
              right: 0.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6.0,
                children: List<Widget>.generate(
                  paths.length,
                  (int index) =>
                      _PageIndicatorDot(isActive: _pageIndex == index),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OutfitImageItem extends StatelessWidget {
  const _OutfitImageItem({
    required this.path,
    required this.source,
    required this.fit,
    required this.onRefresh,
  });

  final String path;
  final OutfitImageSource source;
  final BoxFit fit;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return switch (source) {
      OutfitImageSource.asset => Image.asset(
        path,
        fit: fit,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            __ErrorView(path: path, onRefresh: onRefresh, error: error),
      ),
      OutfitImageSource.file => Image.file(
        File(path),
        fit: fit,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            __ErrorView(path: path, onRefresh: onRefresh, error: error),
      ),
      OutfitImageSource.network => Image.network(
        path,
        fit: fit,
        loadingBuilder:
            (BuildContext _, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Shimmer.fromColors(
                baseColor: colorScheme.surfaceContainerHighest,
                highlightColor: colorScheme.surface.withValues(alpha: 0.5),
                child: ColoredBox(
                  color: colorScheme.surface,
                  child: const SizedBox.expand(),
                ),
              );
            },
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            __ErrorView(path: path, onRefresh: onRefresh, error: error),
      ),
    };
  }
}

class __ErrorView extends StatelessWidget {
  const __ErrorView({
    required this.path,
    required this.onRefresh,
    required this.error,
  });

  final String path;
  final RefreshCallback onRefresh;
  final Object error;

  @override
  Widget build(BuildContext context) {
    debugPrint('⚠️ Failed to load outfit image: "$path". Error: $error');
    return OutfitImageErrorWidget(onRefresh: onRefresh);
  }
}

class _PageIndicatorDot extends StatelessWidget {
  const _PageIndicatorDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 12.0 : 6.0,
      height: 6.0,
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary
            : colorScheme.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}

/// A custom [ScrollBehavior] that allows dragging with a mouse on desktop.
class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  const _MouseDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}
