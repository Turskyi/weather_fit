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
    return Dialog.fullscreen(
      child: WearPositionIndicator(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                translate('search.location_not_found_dialog_title'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                translate('search.location_not_found_suggestion_spell_check'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: widget.onCancel,
                  child: Text(translate('cancel')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
