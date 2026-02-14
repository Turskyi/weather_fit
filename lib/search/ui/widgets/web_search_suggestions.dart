import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/search/ui/widgets/quick_cities_suggestions.dart';

class WebSearchSuggestions extends StatelessWidget {
  const WebSearchSuggestions({
    required this.textEditingController,
    required this.isFocused,
    super.key,
  });

  final TextEditingController textEditingController;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: textEditingController,
      builder: (BuildContext context, TextEditingValue value, Widget? child) {
        final bool hasInput = value.text.trim().isNotEmpty;
        final bool showSuggestions = isFocused && !hasInput;

        return BlocBuilder<SearchBloc, SearchState>(
          builder: (BuildContext _, SearchState state) {
            return QuickCitiesSuggestions(
              isVisible: showSuggestions,
              suggestions: state.quickCitiesSuggestions,
              textEditingController: textEditingController,
            );
          },
        );
      },
    );
  }
}
