import 'package:flutter/material.dart';

/// Calls `builder` on keyboard close/open.
/// https://stackoverflow.com/a/63241360/10636137
class KeyboardVisibilityBuilder extends StatefulWidget {
  const KeyboardVisibilityBuilder({required this.builder, super.key});

  final Widget Function(bool isKeyboardVisible) builder;

  @override
  State<KeyboardVisibilityBuilder> createState() {
    return _KeyboardVisibilityBuilderState();
  }
}

class _KeyboardVisibilityBuilderState extends State<KeyboardVisibilityBuilder>
    with WidgetsBindingObserver {
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final double bottomInset = View.of(context).viewInsets.bottom;
    final bool newValue = bottomInset > 0.0;
    if (newValue != _isKeyboardVisible) {
      setState(() => _isKeyboardVisible = newValue);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(_isKeyboardVisible);
}
