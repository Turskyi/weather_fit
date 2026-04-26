import 'package:flutter/material.dart';
import 'package:weather_fit/res/widgets/wear_position_indicator.dart';

class WearDialog extends StatefulWidget {
  const WearDialog({required this.child, super.key});

  final Widget child;

  @override
  State<WearDialog> createState() => _WearDialogState();
}

class _WearDialogState extends State<WearDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: WearPositionIndicator(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
