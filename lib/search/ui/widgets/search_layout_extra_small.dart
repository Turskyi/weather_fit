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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      context.wearHorizontalPadding,
      math.max(MediaQuery.paddingOf(context).top, 52),
      context.wearHorizontalPadding,
      0,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
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
                                  focusNode: _focusNode,
                                  autofocus: true,
                                  style: textTheme.labelSmall,
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: _onSearchSubmitted,
                                  enableInteractiveSelection: false,
                                  contextMenuBuilder:
                                      (
                                        BuildContext context,
                                        EditableTextState editableTextState,
                                      ) {
                                        return const SizedBox.shrink();
                                      },
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    filled: true,
                                    prefixIcon: SizedBox(
                                      width: 26,
                                      child: IconButton(
                                        onPressed: _focusNode.requestFocus,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.search,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                      minWidth: 28,
                                    ),
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
                                                  _onSearchSubmitted,
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

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    final SearchState state = context.read<SearchBloc>().state;
    if (state is SearchLoading) {
      return;
    } else if (value.trim().isEmpty) {
      _focusNode.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(translate('search.enter_location')),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      context.read<SearchBloc>().add(SearchLocation(value.trim()));
    }
  }
}
