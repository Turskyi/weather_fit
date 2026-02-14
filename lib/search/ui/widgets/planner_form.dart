import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class PlannerForm extends StatelessWidget {
  const PlannerForm({
    required this.locationController,
    required this.selectedDate,
    required this.isLoading,
    required this.errorMessage,
    required this.onSelectDate,
    required this.onGenerate,
    super.key,
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
