import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/temp_option.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/entities/models/search/saved_plan.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/search/ui/widgets/planner_shimmer.dart';
import 'package:weather_fit/weather/ui/widgets/outfit_widget.dart';
import 'package:weather_repository/weather_repository.dart';

class PlannerResult extends StatefulWidget {
  const PlannerResult({
    required this.localDataSource,
    required this.weather,
    required this.date,
    required this.onReset,
    super.key,
  });

  final LocalDataSource localDataSource;
  final WeatherDomain weather;
  final DateTime date;
  final VoidCallback onReset;

  @override
  State<PlannerResult> createState() => _PlannerResultState();
}

class _PlannerResultState extends State<PlannerResult> {
  TempOption _selectedOption = TempOption.typical;
  OutfitImage? _outfitImage;
  String? _recommendation;
  bool _isRefreshing = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    _updateOutfit();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final String minTemp =
        widget.weather.minTemperature?.toStringAsFixed(0) ?? '';
    final String maxTemp =
        widget.weather.maxTemperature?.toStringAsFixed(0) ?? '';
    final String tempRange = minTemp.isNotEmpty && maxTemp.isNotEmpty
        ? translate(
            'search.typical_temperature',
            args: <String, String>{'minTemp': minTemp, 'maxTemp': maxTemp},
          )
        : '';

    final OutfitImage? outfitImage = _outfitImage;
    final String? recommendation = _recommendation;

    final Widget outfitContent;
    if (outfitImage == null || recommendation == null) {
      outfitContent = const PlannerShimmer(
        key: ValueKey<String>('planner_loading'),
      );
    } else {
      outfitContent = Center(
        key: const ValueKey<String>('planner_content'),
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            OutfitWidget(
              outfitImage: outfitImage,
              outfitRecommendation: recommendation,
              onRefresh: _updateOutfit,
            ),
            if (_isRefreshing)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.transparent,
                    highlightColor: colorScheme.surface.withValues(alpha: 0.3),
                    child: Container(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      spacing: 24,
      children: <Widget>[
        Column(
          spacing: 16,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: tempRange.isNotEmpty
                      ? Text(
                          tempRange,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                IconButton(
                  onPressed: _onBookmark,
                  icon: Icon(
                    _isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_add_outlined,
                    color: _isBookmarked ? colorScheme.primary : null,
                  ),
                  tooltip: translate('search.bookmark_plan'),
                ),
              ],
            ),
            SegmentedButton<TempOption>(
              segments: <ButtonSegment<TempOption>>[
                ButtonSegment<TempOption>(
                  value: TempOption.coolest,
                  label: Text(
                    translate('search.temperature_coolest'),
                    style: textTheme.labelMedium,
                  ),
                ),
                ButtonSegment<TempOption>(
                  value: TempOption.typical,
                  label: Text(translate('search.temperature_typical')),
                ),
                ButtonSegment<TempOption>(
                  value: TempOption.warmest,
                  label: Text(
                    translate('search.temperature_warmest'),
                    style: textTheme.labelMedium,
                  ),
                ),
              ],
              selected: <TempOption>{_selectedOption},
              onSelectionChanged: _onTempOptionChanged,
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: outfitContent,
          ),
        ),
        TextButton.icon(
          onPressed: widget.onReset,
          icon: const Icon(Icons.edit_location_alt_outlined),
          label: Text(translate('search.change_details_button')),
        ),
      ],
    );
  }

  void _checkBookmarkStatus() {
    final List<SavedPlan> plans = widget.localDataSource.getSavedPlans();
    final SavedPlan currentPlan = SavedPlan(
      cityName: widget.weather.locationName,
      date: widget.date,
    );
    setState(() {
      _isBookmarked = plans.any(
        (SavedPlan p) =>
            p.cityName == currentPlan.cityName &&
            p.date.isAtSameMomentAs(currentPlan.date),
      );
    });
  }

  Future<void> _updateOutfit() async {
    setState(() => _isRefreshing = true);

    final double targetTemp = switch (_selectedOption) {
      TempOption.coolest =>
        widget.weather.minTemperature ?? widget.weather.temperature,
      TempOption.typical => widget.weather.temperature,
      TempOption.warmest =>
        widget.weather.maxTemperature ?? widget.weather.temperature,
    };

    final Weather weather = Weather.fromDomain(
      widget.weather,
    ).copyWith(temperature: Temperature(value: targetTemp));

    final OutfitRepository outfitRepository = context.read<OutfitRepository>();
    final String recommendation = outfitRepository.getOutfitRecommendation(
      weather,
    );
    final OutfitImage outfitImage = await outfitRepository.getOutfitImage(
      weather,
    );

    if (mounted) {
      setState(() {
        _recommendation = recommendation;
        _outfitImage = outfitImage;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _onBookmark() async {
    HapticFeedback.mediumImpact();
    final SavedPlan plan = SavedPlan(
      cityName: widget.weather.locationName,
      date: widget.date,
      weather: widget.weather,
    );

    if (_isBookmarked) {
      final List<SavedPlan> plans = widget.localDataSource.getSavedPlans();
      final SavedPlan? planToRemove = plans
          .where(
            (SavedPlan p) =>
                p.cityName == plan.cityName &&
                p.date.isAtSameMomentAs(plan.date),
          )
          .firstOrNull;

      if (planToRemove != null) {
        await widget.localDataSource.removePlan(planToRemove);
      }

      if (mounted) {
        setState(() => _isBookmarked = false);
      }
    } else {
      await widget.localDataSource.savePlan(plan);
      if (mounted) {
        setState(() => _isBookmarked = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate('search.plan_saved')),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onTempOptionChanged(Set<TempOption> newSelection) {
    setState(() {
      _selectedOption = newSelection.first;
    });
    _updateOutfit();
  }
}
