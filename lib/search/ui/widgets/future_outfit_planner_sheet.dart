import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/search/ui/widgets/header.dart';
import 'package:weather_fit/search/ui/widgets/planner_form.dart';
import 'package:weather_fit/search/ui/widgets/planner_result.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';
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
            const Header(),
            const SizedBox(height: 16),
            if (outfitImage == null ||
                recommendation == null ||
                weather == null)
              PlannerForm(
                locationController: _locationController,
                selectedDate: _selectedDate,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                onSelectDate: () => _selectDate(context),
                onGenerate: _onGeneratePreview,
              )
            else
              PlannerResult(
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
