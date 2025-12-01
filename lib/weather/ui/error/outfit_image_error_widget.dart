import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class OutfitImageErrorWidget extends StatelessWidget {
  const OutfitImageErrorWidget({required this.onRefresh, super.key});

  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.broken_image, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            translate('unable_to_load_outfit_image'),
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            translate('please_try_refreshing_weather'),
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRefresh,
            child: Text(translate('get_new_outfit_suggestion')),
          ),
        ],
      ),
    );
  }
}
