import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingOutfitTextWidget extends StatelessWidget {
  const LoadingOutfitTextWidget({
    required this.displayText,
    super.key,
  });

  final String displayText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Shimmer.fromColors(
          baseColor: colorScheme.primaryContainer,
          highlightColor: colorScheme.onPrimary,
          child: Container(color: colorScheme.secondaryContainer),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SelectableText(
            displayText,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
