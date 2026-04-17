import 'package:flutter/material.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/widgets/wear_position_indicator.dart';

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

  void _showWearSelectionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final ScrollController scrollController = ScrollController();
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: WearPositionIndicator(
            controller: scrollController,
            child: ListView.builder(
              controller: scrollController,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final int option = options[index];
                final bool isSelected = option == value;
                return ListTile(
                  title: Text(
                    '${option.toString().padLeft(2, '0')}:00',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    onChanged(option);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color watchForegroundColor = context.watchForegroundColor;
    final bool isWear = context.isExtraSmallScreen;

    final Widget labelWidget = Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: watchForegroundColor),
      textAlign: TextAlign.center,
    );

    if (isWear) {
      return Column(
        children: <Widget>[
          labelWidget,
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _showWearSelectionDialog(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${value.toString().padLeft(2, '0')}:00',
                    style: TextStyle(color: watchForegroundColor),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: watchForegroundColor.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        labelWidget,
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
