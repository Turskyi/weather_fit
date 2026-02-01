import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/search/ui/widgets/future_outfit_planner_sheet.dart';
import 'package:weather_fit/search/ui/widgets/quick_cities_suggestions.dart';
import 'package:weather_fit/widgets/keyboard_visibility_builder.dart';

class SearchLayoutDefault extends StatefulWidget {
  const SearchLayoutDefault({
    required this.textEditingController,
    required this.searchStateListener,
    super.key,
  });

  final TextEditingController textEditingController;

  /// Takes the `BuildContext` along with the [bloc] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocWidgetListener<SearchState> searchStateListener;

  @override
  State<SearchLayoutDefault> createState() => _SearchLayoutDefaultState();
}

class _SearchLayoutDefaultState extends State<SearchLayoutDefault> {
  late final FocusNode _searchFieldFocus;
  bool _isSearchFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFieldFocus = FocusNode();
    _searchFieldFocus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchFieldFocus.removeListener(_onFocusChanged);
    _searchFieldFocus.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isSearchFieldFocused = _searchFieldFocus.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: colorScheme.surface.withValues(alpha: 0.2)),
          ),
        ),
        leading: kIsWeb ? const LeadingWidget() : null,
        title: KeyboardVisibilityBuilder(
          builder: (bool isKeyboardVisible) {
            final Orientation orientation = MediaQuery.of(context).orientation;
            final bool isLandscapeOrientation =
                orientation == Orientation.landscape;
            return Text(
              isLandscapeOrientation && isKeyboardVisible
                  ? ''
                  : translate('search.page_app_bar_title'),
            );
          },
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16.0,
            children: <Widget>[
              const Spacer(flex: 1),
              Text(
                '🏙️',
                style: TextStyle(fontSize: textTheme.displayLarge?.fontSize),
              ),
              Text(
                translate('explore_weather_prompt'),
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                translate('search.instructions'),
                style: textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                constraints: BoxConstraints(maxWidth: context.maxWidth),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(28.0),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            focusNode: _searchFieldFocus,
                            controller: widget.textEditingController,
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (String value) {
                              _onSearchSubmitted(
                                context: context,
                                value: value,
                              );
                            },
                            style: textTheme.bodyLarge,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  Icons.search,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              hintText: translate('search.city_or_country'),
                              hintStyle: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 16.0,
                              ),
                            ),
                          ),
                          if (kIsWeb)
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: widget.textEditingController,
                              builder:
                                  (
                                    BuildContext context,
                                    TextEditingValue value,
                                    Widget? child,
                                  ) {
                                    final bool hasInput = value.text
                                        .trim()
                                        .isNotEmpty;
                                    final bool showSuggestions =
                                        _isSearchFieldFocused && !hasInput;

                                    return BlocBuilder<SearchBloc, SearchState>(
                                      builder:
                                          (BuildContext _, SearchState state) {
                                            return QuickCitiesSuggestions(
                                              isVisible: showSuggestions,
                                              suggestions:
                                                  state.quickCitiesSuggestions,
                                              textEditingController:
                                                  widget.textEditingController,
                                            );
                                          },
                                    );
                                  },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              BlocConsumer<SearchBloc, SearchState>(
                listener: widget.searchStateListener,
                builder: (BuildContext _, SearchState state) {
                  final double progressIndicatorSize = 20.0;
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: widget.textEditingController,
                    child: state is SearchLoading
                        ? SizedBox(
                            height: progressIndicatorSize,
                            width: progressIndicatorSize,
                            child: const CircularProgressIndicator(),
                          )
                        : Text(
                            translate('submit'),
                            semanticsLabel: translate('submit'),
                          ),
                    builder:
                        (
                          BuildContext context,
                          TextEditingValue value,
                          Widget? textSubmit,
                        ) {
                          return ElevatedButton(
                            key: const Key('searchPage_search_iconButton'),
                            onPressed:
                                state is! SearchLoading &&
                                    value.text.trim().isNotEmpty
                                ? () {
                                    _onSearchSubmitted(
                                      context: context,
                                      value: value.text,
                                    );
                                  }
                                : null,
                            child: textSubmit,
                          );
                        },
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (BuildContext _) {
                      return const FutureOutfitPlannerSheet();
                    },
                  );
                },
                icon: const Icon(Icons.auto_awesome),
                label: Text(translate('search.plan_future_outfit')),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }

  void _onSearchSubmitted({
    required BuildContext context,
    required String value,
  }) {
    final SearchState state = context.read<SearchBloc>().state;
    if (state is! SearchLoading && value.trim().isNotEmpty) {
      context.read<SearchBloc>().add(SearchLocation(value));
    }
  }
}
