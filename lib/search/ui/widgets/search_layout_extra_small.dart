import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';

class SearchPageExtraSmallLayout extends StatelessWidget {
  const SearchPageExtraSmallLayout({
    required this.textEditingController,
    required this.searchStateListener,
    required this.languageIsoCode,
    super.key,
  });

  final TextEditingController textEditingController;

  /// Takes the `BuildContext` along with the [bloc] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocWidgetListener<SearchState> searchStateListener;

  final String languageIsoCode;

  void _onSearchSubmitted(BuildContext context, String value) {
    final SearchState state = context.read<SearchBloc>().state;
    if (state is! SearchLoading && value.trim().isNotEmpty) {
      context.read<SearchBloc>().add(SearchLocation(value.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: <Widget>[
                TextField(
                  controller: textEditingController,
                  autofocus: true,
                  style: textTheme.labelSmall,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (String value) =>
                      _onSearchSubmitted(context, value),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: translate('search.enter_city_or_country'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                BlocConsumer<SearchBloc, SearchState>(
                  listener: searchStateListener,
                  builder: (BuildContext _, SearchState state) {
                    final double progressIndicatorSize = 20.0;
                    return ValueListenableBuilder<TextEditingValue>(
                      valueListenable: textEditingController,
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
                            final String valueText = value.text.trim();
                            return ElevatedButton(
                              key: const Key('searchPage_search_iconButton'),
                              onPressed:
                                  state is! SearchLoading &&
                                      valueText.isNotEmpty
                                  ? () => _onSearchSubmitted(context, valueText)
                                  : null,
                              child: textSubmit,
                            );
                          },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
