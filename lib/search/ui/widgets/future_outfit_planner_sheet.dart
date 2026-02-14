import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/entities/models/temperature/temperature.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
import 'package:weather_fit/weather/ui/widgets/outfit_widget.dart';
import 'package:weather_repository/weather_repository.dart';

class FutureOutfitPlannerSheet extends StatefulWidget {
  const FutureOutfitPlannerSheet({super.key});

  @override
  State<FutureOutfitPlannerSheet> createState() =>
      _FutureOutfitPlannerSheetState();
}

class _FutureOutfitPlannerSheetState extends State<FutureOutfitPlannerSheet> {
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;

  OutfitImage? _resultOutfitImage;
  String? _resultRecommendation;
  WeatherDomain? _resultWeather;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 2)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _onGeneratePreview() async {
    final String query = _locationController.text.trim();
    if (query.isEmpty) return;
    final DateTime? date = _selectedDate;
    if (date == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resultOutfitImage = null;
      _resultWeather = null;
    });

    try {
      final WeatherRepository weatherRepository = context
          .read<WeatherRepository>();

      // 1. Resolve Location (independent flow, no GPS)
      final Location location = await weatherRepository.searchLocation(
        query: query,
        locale: context.read<SettingsBloc>().state.locale,
      );

      if (mounted) {
        final bool? confirmed = await _showLocationConfirmationDialog(location);
        if (confirmed == true) {
          await _fetchProjectionAndOutfit(location, date);
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = translate(
              'search.location_not_found_clarification',
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = translate('search.location_not_found_clarification');
        });
      }
    }
  }

  Future<void> _fetchProjectionAndOutfit(
    Location location,
    DateTime date,
  ) async {
    try {
      final WeatherRepository weatherRepository = context
          .read<WeatherRepository>();
      final OutfitRepository outfitRepository = context
          .read<OutfitRepository>();

      // 2. Fetch Climate Projection
      final WeatherDomain weatherDomain = await weatherRepository
          .getClimateProjection(location: location, date: date);

      // Convert Domain to App Weather model for the OutfitRepository
      final Weather weather = Weather.fromDomain(weatherDomain);

      // 3. Get Outfit Recommendation
      final String recommendation = outfitRepository.getOutfitRecommendation(
        weather,
      );
      final OutfitImage outfitImage = await outfitRepository.getOutfitImage(
        weather,
      );

      if (mounted) {
        setState(() {
          _resultOutfitImage = outfitImage;
          _resultRecommendation = recommendation;
          _resultWeather = weatherDomain;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = translate('search.projection_fetch_failed');
        });
      }
    }
  }

  Future<bool?> _showLocationConfirmationDialog(Location location) {
    final List<String> parts = <String>[location.name];
    if (location.province.isNotEmpty) parts.add(location.province);
    if (location.country.isNotEmpty) parts.add(location.country);
    final String displayLocation = parts.join(', ');

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('search.confirm_location_dialog_title')),
          content: Text(displayLocation),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(translate('no')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(translate('yes')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final OutfitImage? outfitImage = _resultOutfitImage;
    final String? recommendation = _resultRecommendation;
    final WeatherDomain? weather = _resultWeather;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _Header(),
            const SizedBox(height: 16),
            if (outfitImage == null ||
                recommendation == null ||
                weather == null)
              _PlannerForm(
                locationController: _locationController,
                selectedDate: _selectedDate,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                onSelectDate: () => _selectDate(context),
                onGenerate: _onGeneratePreview,
              )
            else
              _PlannerResult(
                weather: weather,
                onReset: () {
                  setState(() {
                    _resultOutfitImage = null;
                    _resultRecommendation = null;
                    _resultWeather = null;
                  });
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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

class _PlannerForm extends StatelessWidget {
  const _PlannerForm({
    required this.locationController,
    required this.selectedDate,
    required this.isLoading,
    required this.errorMessage,
    required this.onSelectDate,
    required this.onGenerate,
  });

  final TextEditingController locationController;
  final DateTime? selectedDate;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSelectDate;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime? date = selectedDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: locationController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: translate('search.destination_label'),
            hintText: translate('search.city_or_country_hint'),
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: const OutlineInputBorder(),
            errorText: errorMessage,
            errorMaxLines: 2,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: onSelectDate,
          borderRadius: BorderRadius.circular(4),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: translate('search.date_label'),
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              border: const OutlineInputBorder(),
            ),
            child: Text(
              date == null
                  ? translate('search.select_date')
                  : '${date.day}.${date.month}.${date.year}',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          translate('search.climate_projection_disclaimer'),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: locationController,
          builder: (BuildContext context, TextEditingValue value, Widget? _) {
            final bool isButtonEnabled =
                !isLoading && value.text.trim().isNotEmpty && date != null;

            return ElevatedButton(
              onPressed: isButtonEnabled ? onGenerate : null,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(translate('search.generate_preview_button')),
            );
          },
        ),
      ],
    );
  }
}

enum _TempOption { coolest, typical, warmest }

class _PlannerResult extends StatefulWidget {
  const _PlannerResult({required this.weather, required this.onReset});

  final WeatherDomain weather;
  final VoidCallback onReset;

  @override
  State<_PlannerResult> createState() => _PlannerResultState();
}

class _PlannerResultState extends State<_PlannerResult> {
  _TempOption _selectedOption = _TempOption.typical;
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
      _TempOption.coolest =>
        widget.weather.minTemperature ?? widget.weather.temperature,
      _TempOption.typical => widget.weather.temperature,
      _TempOption.warmest =>
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
        SegmentedButton<_TempOption>(
          segments: <ButtonSegment<_TempOption>>[
            ButtonSegment<_TempOption>(
              value: _TempOption.coolest,
              label: Text(translate('search.temperature_coolest')),
            ),
            ButtonSegment<_TempOption>(
              value: _TempOption.typical,
              label: Text(translate('search.temperature_typical')),
            ),
            ButtonSegment<_TempOption>(
              value: _TempOption.warmest,
              label: Text(translate('search.temperature_warmest')),
            ),
          ],
          selected: <_TempOption>{_selectedOption},
          onSelectionChanged: (Set<_TempOption> newSelection) {
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
