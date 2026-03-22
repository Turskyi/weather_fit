import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';

class SearchButtons extends StatelessWidget {
  const SearchButtons({
    required this.query,
    required this.isLoading,
    required this.onSearchSubmitted,
    this.showGpsButton = true,
    super.key,
  });

  final String query;
  final bool isLoading;
  final ValueSetter<String> onSearchSubmitted;
  final bool showGpsButton;

  @override
  Widget build(BuildContext context) {
    const double progressIndicatorSize = 20.0;
    final ColorScheme colors = Theme.of(context).colorScheme;

    final ButtonStyle elevatedStyle = ElevatedButton.styleFrom(
      disabledBackgroundColor: colors.surfaceContainerHighest.withValues(
        alpha: 0.88,
      ),
      disabledForegroundColor: colors.onSurface.withValues(alpha: 0.82),
    );

    final ButtonStyle gpsStyle = TextButton.styleFrom(
      foregroundColor: colors.primary,
      disabledForegroundColor: colors.onSurface.withValues(alpha: 0.82),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        ElevatedButton(
          style: elevatedStyle,
          key: const Key('searchPage_search_iconButton'),
          onPressed: !isLoading && query.trim().isNotEmpty
              ? () => onSearchSubmitted(query)
              : null,
          child: isLoading
              ? const SizedBox(
                  height: progressIndicatorSize,
                  width: progressIndicatorSize,
                  child: CircularProgressIndicator(),
                )
              : Text(translate('submit'), semanticsLabel: translate('submit')),
        ),
        if (showGpsButton)
          TextButton.icon(
            style: gpsStyle,
            onPressed: isLoading
                ? null
                : () {
                    context.read<SearchBloc>().add(
                      const RequestPermissionAndSearchByLocation(''),
                    );
                  },
            icon: const Icon(Icons.location_on),
            label: Text(translate('search.use_gps_button')),
          ),
      ],
    );
  }
}
