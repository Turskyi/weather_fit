import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/enums/temp_option.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/weather/ui/widgets/outfit_widget.dart';
import 'package:weather_repository/weather_repository.dart';

class PlannerResult extends StatefulWidget {
  const PlannerResult({
    required this.weather,
    required this.onReset,
    super.key,
  });

  final WeatherDomain weather;
  final VoidCallback onReset;

  @override
  State<PlannerResult> createState() => _PlannerResultState();
}

class _PlannerResultState extends State<PlannerResult> {
  TempOption _selectedOption = TempOption.typical;
  OutfitImage? _outfitImage;
  String? _recommendation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _updateOutfit();
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

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

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
        if (tempRange.isNotEmpty) ...<Widget>[
          Text(
            tempRange,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
        ],
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
