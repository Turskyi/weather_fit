import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_fit/entities/models/search/saved_plan.dart';

class PlanSuggestionTile extends StatefulWidget {
  const PlanSuggestionTile({
    required this.plan,
    required this.onTap,
    super.key,
  });

  final SavedPlan plan;
  final VoidCallback onTap;

  @override
  State<PlanSuggestionTile> createState() => _PlanSuggestionTileState();
}

class _PlanSuggestionTileState extends State<PlanSuggestionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DateTime date = widget.plan.date;

    return MouseRegion(
      onEnter: (PointerEnterEvent _) => setState(() => _isHovered = true),
      onExit: (PointerExitEvent _) => setState(() => _isHovered = false),
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
                const Icon(Icons.history, size: 20),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.plan.cityName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: _isHovered
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        '${date.day}.${date.month}.${date.year}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
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
