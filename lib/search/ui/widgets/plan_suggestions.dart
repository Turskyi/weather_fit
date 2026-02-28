import 'package:flutter/material.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/entities/models/search/saved_plan.dart';
import 'package:weather_fit/search/ui/widgets/plan_suggestion_tile.dart';

class PlanSuggestions extends StatelessWidget {
  const PlanSuggestions({
    required this.localDataSource,
    required this.onPlanSelected,
    super.key,
  });

  final LocalDataSource localDataSource;
  final ValueChanged<SavedPlan> onPlanSelected;

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
          PlanSuggestionTile(plan: plan, onTap: () => onPlanSelected(plan)),
      ],
    );
  }
}
