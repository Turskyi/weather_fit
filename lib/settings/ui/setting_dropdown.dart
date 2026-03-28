import 'package:flutter/material.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';

class SettingDropdown extends StatelessWidget {
  const SettingDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String label;
  final int value;
  final List<int> options;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white12,
          ),
          child: DropdownButton<int>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: Colors.black,
            style: TextStyle(color: watchForegroundColor),
            items: options.map((int hour) {
              return DropdownMenuItem<int>(
                value: hour,
                child: Text('${hour.toString().padLeft(2, '0')}:00'),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
