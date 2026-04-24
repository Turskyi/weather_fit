import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class SearchLocationPlaceholder extends StatelessWidget {
  const SearchLocationPlaceholder({
    required this.textEditingController,
    super.key,
  });

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: textEditingController,
      builder: (BuildContext context, TextEditingValue value, Widget? _) {
        return Text(
          value.text.isEmpty ? translate('search.enter_location') : value.text,
          style: textTheme.labelSmall?.copyWith(
            color: value.text.isEmpty
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
