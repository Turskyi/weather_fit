import 'package:flutter/material.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/models/search/saved_plan.dart';

class PlanSuggestions extends StatelessWidget {
  const PlanSuggestions({
    required this.localDataSource,
    required this.onPlanSelected,
    super.key,
  });

  final LocalDataSource localDataSource;
  final void Function(String cityName, DateTime date) onPlanSelected;

  @override
  Widget build(BuildContext context) {
    final List<SavedPlan> plans = localDataSource.getSavedPlans();

    if (plans.isEmpty) {
      return const SizedBox.shrink();
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 16),
        Divider(height: 1, color: colorScheme.onSurface.withValues(alpha: 0.1)),
        for (final SavedPlan plan in plans.reversed)
          _PlanSuggestionTile(
            plan: plan,
            onTap: () {
              onPlanSelected(plan.cityName, plan.date);
            },
          ),
      ],
    );
  }
}

class _PlanSuggestionTile extends StatefulWidget {
  const _PlanSuggestionTile({required this.plan, required this.onTap});

  final SavedPlan plan;
  final VoidCallback onTap;

  @override
  State<_PlanSuggestionTile> createState() => _PlanSuggestionTileState();
}

class _PlanSuggestionTileState extends State<_PlanSuggestionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DateTime date = widget.plan.date;

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
