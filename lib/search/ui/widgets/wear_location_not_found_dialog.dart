import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/res/widgets/wear_position_indicator.dart';

class WearLocationNotFoundDialog extends StatefulWidget {
  const WearLocationNotFoundDialog({required this.onCancel, super.key});

  final VoidCallback onCancel;

  @override
  State<WearLocationNotFoundDialog> createState() =>
      _WearLocationNotFoundDialogState();
}

class _WearLocationNotFoundDialogState
    extends State<WearLocationNotFoundDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: themeData.colorScheme.primary,
      brightness: Brightness.dark,
    );

    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: WearPositionIndicator(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12,
            children: <Widget>[
              Text(
                translate('search.location_not_found_dialog_title'),
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                translate('search.location_not_found_suggestion_spell_check'),
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: widget.onCancel,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                ),
                child: Text(translate('cancel')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
