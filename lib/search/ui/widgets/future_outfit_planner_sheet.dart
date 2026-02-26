import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nominatim_api/nominatim_api.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/data/repositories/location_repository.dart';
import 'package:weather_fit/data/repositories/outfit_repository.dart';
import 'package:weather_fit/entities/models/outfit/outfit_image.dart';
import 'package:weather_fit/entities/models/weather/weather.dart';
import 'package:weather_fit/search/ui/widgets/header.dart';
import 'package:weather_fit/search/ui/widgets/planner_form.dart';
import 'package:weather_fit/search/ui/widgets/planner_result.dart';
import 'package:weather_repository/weather_repository.dart';

class FutureOutfitPlannerSheet extends StatefulWidget {
  const FutureOutfitPlannerSheet({required this.localDataSource, super.key});

  final LocalDataSource localDataSource;

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
  void initState() {
    super.initState();
    _cleanupPastPlans();
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
                localDataSource: widget.localDataSource,
                locationController: _locationController,
                selectedDate: _selectedDate,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                onSelectDate: () => _selectDate(context),
                onGenerate: _onGeneratePreview,
                onDateSelected: (DateTime date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                onPlanSelected: _onPlanSelected,
              )
            else
              PlannerResult(
                localDataSource: widget.localDataSource,
                weather: weather,
                date: _selectedDate ?? DateTime.now(),
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

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  String _mapExceptionToMessage(Object e, {required String defaultMessage}) {
    final String errorString = e.toString();
    if (e is SocketException ||
        errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup') ||
        errorString.contains('HandshakeException') ||
        errorString.contains('Connection refused') ||
        errorString.contains('Connection closed')) {
      return translate('error.network_error');
    }
    return defaultMessage;
  }

  Future<void> _showLocationNotFoundDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(translate('search.location_not_found_dialog_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                translate('search.location_not_found_suggestion_spell_check'),
              ),
              const SizedBox(height: 16),
              Text(translate('search.location_not_found_suggestion_use_gps')),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: Navigator.of(dialogContext).pop,
              child: Text(translate('cancel')),
            ),
            TextButton(
              autofocus: true,
              child: Text(translate('ok')),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showLocationConfirmationDialog(Location location) {
    // Build a list of non-empty location parts for a consistent UI.
    final List<String> parts = <String>[location.name];
    if (location.province.isNotEmpty) {
      parts.add(location.province);
    }
    if (location.country.isNotEmpty) {
      parts.add(location.country);
    }
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
              autofocus: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(translate('yes')),
            ),
          ],
        );
      },
    );
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

      // Fetch Climate Projection for the resolved location.
      final WeatherDomain weatherDomain = await weatherRepository
          .getClimateProjection(location: location, date: date);

      final Weather weather = Weather.fromDomain(weatherDomain);

      // Get Outfit Recommendation and image.
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
          _errorMessage = _mapExceptionToMessage(
            e,
            defaultMessage: translate('search.projection_fetch_failed'),
          );
        });
      }
    }
  }

  Future<void> _onGeneratePreview({bool skipConfirmation = false}) async {
    if (_isLoading) return;

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
      final LocationRepository locationRepository = context
          .read<LocationRepository>();

      // Similar to SearchBloc, we use LocationRepository to resolve the query.
      final Location location = await locationRepository.getLocation(query);

      if (mounted) {
        if (skipConfirmation) {
          await _fetchProjectionAndOutfit(location, date);
        } else {
          final bool? confirmed = await _showLocationConfirmationDialog(
            location,
          );
          if (confirmed == true) {
            await _fetchProjectionAndOutfit(location, date);
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (e is LocationNotFoundFailure ||
            e is NominatimLocationRequestFailure) {
          _showLocationNotFoundDialog();
        } else {
          setState(() {
            _errorMessage = _mapExceptionToMessage(
              e,
              defaultMessage: translate(
                'search.location_not_found_clarification',
              ),
            );
          });
        }
      }
    }
  }

  Future<void> _onPlanSelected(String cityName, DateTime date) async {
    if (_isLoading) return;
    setState(() {
      _locationController.text = cityName;
      _selectedDate = date;
    });
    await _onGeneratePreview(skipConfirmation: true);
  }

  Future<void> _cleanupPastPlans() async {
    await widget.localDataSource.removePastPlans();
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
}
