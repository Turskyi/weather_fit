import 'package:flutter/material.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';

class SettingSegmentedToggle extends StatelessWidget {
  const SettingSegmentedToggle({
    required this.label,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final String label;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color watchForegroundColor = context.watchForegroundColor;

    return Column(
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: watchForegroundColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorScheme.onSurface.withValues(alpha: 0.12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List<Widget>.generate(options.length, (int index) {
              final bool isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      options[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : watchForegroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
