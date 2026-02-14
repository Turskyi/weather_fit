import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Icon(Icons.auto_awesome, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            translate('search.outfit_planner_title'),
            style: textTheme.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
