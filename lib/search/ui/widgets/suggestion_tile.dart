import 'package:flutter/material.dart';
import 'package:weather_fit/entities/models/quick_city_suggestion.dart';

/// Individual suggestion tile with hover effects.
class SuggestionTile extends StatefulWidget {
  const SuggestionTile({
    required this.suggestion,
    required this.onTap,
    required this.isLast,
    super.key,
  });

  final QuickCitySuggestion suggestion;
  final VoidCallback onTap;
  final bool isLast;

  @override
  State<SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<SuggestionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered
            ? colorScheme.onSurface.withValues(alpha: 0.08)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 14.0,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  widget.suggestion.flag,
                  style: const TextStyle(fontSize: 20.0),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    widget.suggestion.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: _isHovered
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.north_west,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
