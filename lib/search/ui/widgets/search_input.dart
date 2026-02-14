import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/search/ui/widgets/web_search_suggestions.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({
    required this.textEditingController,
    required this.focusNode,
    required this.isFocused,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final bool isFocused;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
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
            focusNode: focusNode,
            controller: textEditingController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
            style: textTheme.bodyLarge,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.search,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              hintText: translate('search.city_or_country'),
              hintStyle: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
            ),
          ),
          if (kIsWeb)
            WebSearchSuggestions(
              textEditingController: textEditingController,
              isFocused: isFocused,
            ),
        ],
      ),
    );
  }
}
