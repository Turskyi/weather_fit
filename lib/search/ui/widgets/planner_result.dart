import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/temp_option.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/entities/models/search/saved_plan.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
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

  void _checkBookmarkStatus() {
    final List<SavedPlan> plans = widget.localDataSource.getSavedPlans();
    final SavedPlan currentPlan = SavedPlan(
      cityName: widget.weather.locationName,
      date: widget.date,
    );
    setState(() {
      _isBookmarked = plans.contains(currentPlan);
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
    );

    if (_isBookmarked) {
      await widget.localDataSource.removePlan(plan);
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

    return Column(
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
                _isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
                color: _isBookmarked ? colorScheme.primary : null,
              ),
              tooltip: translate('search.bookmark_plan'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SegmentedButton<TempOption>(
          segments: <ButtonSegment<TempOption>>[
            ButtonSegment<TempOption>(
              value: TempOption.coolest,
              label: Text(translate('search.temperature_coolest')),
            ),
            ButtonSegment<TempOption>(
              value: TempOption.typical,
              label: Text(translate('search.temperature_typical')),
            ),
            ButtonSegment<TempOption>(
              value: TempOption.warmest,
              label: Text(translate('search.temperature_warmest')),
            ),
          ],
          selected: <TempOption>{_selectedOption},
          onSelectionChanged: (Set<TempOption> newSelection) {
            setState(() {
              _selectedOption = newSelection.first;
            });
            _updateOutfit();
          },
        ),
        const SizedBox(height: 24),
        if (_isRefreshing || _outfitImage == null || _recommendation == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          OutfitWidget(
            outfitImage: _outfitImage!,
            outfitRecommendation: _recommendation!,
            onRefresh: () async => _updateOutfit(),
          ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: widget.onReset,
          icon: const Icon(Icons.edit_location_alt_outlined),
          label: Text(translate('search.change_details_button')),
        ),
      ],
    );
  }
}
