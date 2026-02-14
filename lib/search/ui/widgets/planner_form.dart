import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/data/data_sources/local/local_data_source.dart';
import 'package:weather_fit/search/ui/widgets/plan_suggestions.dart';

class PlannerForm extends StatefulWidget {
  const PlannerForm({
    required this.localDataSource,
    required this.locationController,
    required this.selectedDate,
    required this.isLoading,
    required this.errorMessage,
    required this.onSelectDate,
    required this.onGenerate,
    required this.onDateSelected,
    required this.onPlanSelected,
    super.key,
  });

  final LocalDataSource localDataSource;
  final TextEditingController locationController;
  final DateTime? selectedDate;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSelectDate;
  final VoidCallback onGenerate;
  final ValueChanged<DateTime> onDateSelected;
  final void Function(String cityName, DateTime date) onPlanSelected;

  @override
  State<PlannerForm> createState() => _PlannerFormState();
}

class _PlannerFormState extends State<PlannerForm> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime? date = widget.selectedDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: _isFocused
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.12),
              width: _isFocused ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: widget.locationController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: translate('search.destination_label'),
                  hintText: translate('search.city_or_country_hint'),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  errorText: widget.errorMessage,
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.locationController,
                builder: (BuildContext context, TextEditingValue value, _) {
                  final bool hasInput = value.text.trim().isNotEmpty;
                  if (_isFocused && !hasInput) {
                    return PlanSuggestions(
                      localDataSource: widget.localDataSource,
                      onPlanSelected: (String cityName, DateTime date) {
                        widget.onPlanSelected(cityName, date);
                        _focusNode.unfocus();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: widget.onSelectDate,
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
          valueListenable: widget.locationController,
          builder: (BuildContext context, TextEditingValue value, Widget? _) {
            final bool isButtonEnabled =
                !widget.isLoading &&
                value.text.trim().isNotEmpty &&
                date != null;

            return ElevatedButton(
              onPressed: isButtonEnabled ? widget.onGenerate : null,
              child: widget.isLoading
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
