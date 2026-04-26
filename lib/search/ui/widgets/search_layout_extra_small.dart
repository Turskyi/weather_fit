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
import 'package:weather_fit/search/ui/widgets/search_location_placeholder.dart';
import 'package:weather_fit/services/device_type_service.dart'
    as device_service;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto-open the native input dialog when the page is loaded.
      // Small delay to ensure the page transition is finished.
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _onSearchBoxTapped();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                                InkWell(
                                  onTap: _onSearchBoxTapped,
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withValues(alpha: 0.92),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        const Icon(Icons.search, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: SearchLocationPlaceholder(
                                            textEditingController:
                                                widget.textEditingController,
                                          ),
                                        ),
                                      ],
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
    super.dispose();
  }

  Future<void> _onSearchBoxTapped() async {
    final String? result = await device_service.openRemoteInput(
      label: translate('search.enter_location'),
    );
    if (result != null && mounted) {
      widget.textEditingController.text = result;
      _onSearchSubmitted(result);
    }
  }

  void _onSearchSubmitted(String value) {
    final SearchState state = context.read<SearchBloc>().state;
    if (state is SearchLoading) {
      return;
    } else if (value.trim().isEmpty) {
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
