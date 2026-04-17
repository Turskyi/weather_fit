import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/res/widgets/wear_position_indicator.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/search/ui/widgets/search_buttons.dart';

class SearchPageExtraSmallLayout extends StatefulWidget {
  const SearchPageExtraSmallLayout({
    required this.textEditingController,
    required this.searchStateListener,
    super.key,
  });

  final TextEditingController textEditingController;

  /// Takes the `BuildContext` along with the [bloc] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocWidgetListener<SearchState> searchStateListener;

  @override
  State<SearchPageExtraSmallLayout> createState() {
    return _SearchPageExtraSmallLayoutState();
  }
}

class _SearchPageExtraSmallLayoutState
    extends State<SearchPageExtraSmallLayout> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(BuildContext context, String value) {
    final SearchState state = context.read<SearchBloc>().state;
    if (state is! SearchLoading && value.trim().isNotEmpty) {
      context.read<SearchBloc>().add(SearchLocation(value.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      context.wearHorizontalPadding,
      math.max(MediaQuery.paddingOf(context).top, 32),
      context.wearHorizontalPadding,
      0,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: LeadingWidget(),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: <Widget>[
          const Background(),
          WearPositionIndicator(
            controller: _scrollController,
            child: Padding(
              padding: contentPadding,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      primary: false,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                TextField(
                                  controller: widget.textEditingController,
                                  autofocus: true,
                                  style: textTheme.labelSmall,
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (String value) =>
                                      _onSearchSubmitted(context, value),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withValues(alpha: 0.92),
                                    hintText: translate(
                                      'search.enter_location',
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                BlocConsumer<SearchBloc, SearchState>(
                                  listener: widget.searchStateListener,
                                  builder: (BuildContext _, SearchState state) {
                                    return ValueListenableBuilder<
                                      TextEditingValue
                                    >(
                                      valueListenable:
                                          widget.textEditingController,
                                      builder:
                                          (
                                            BuildContext context,
                                            TextEditingValue value,
                                            Widget? _,
                                          ) {
                                            return SearchButtons(
                                              query: value.text,
                                              isLoading: state is SearchLoading,
                                              onSearchSubmitted:
                                                  (String query) =>
                                                      _onSearchSubmitted(
                                                        context,
                                                        query,
                                                      ),
                                              showGpsButton: false,
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
