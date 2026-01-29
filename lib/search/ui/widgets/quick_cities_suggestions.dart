import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/entities/models/quick_city_suggestion.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';

/// Displays quick city suggestions as an animated list.
/// Shown when the search field is focused and hidden when user starts typing.
class QuickCitiesSuggestions extends StatefulWidget {
  const QuickCitiesSuggestions({
    required this.isVisible,
    required this.suggestions,
    required this.textEditingController,
    super.key,
  });

  final bool isVisible;
  final List<QuickCitySuggestion> suggestions;
  final TextEditingController textEditingController;

  @override
  State<QuickCitiesSuggestions> createState() => _QuickCitiesSuggestionsState();
}

class _QuickCitiesSuggestionsState extends State<QuickCitiesSuggestions>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightFactorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightFactorAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    if (widget.isVisible) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(QuickCitiesSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Feature is temporarily limited to Web.
    if (!kIsWeb || widget.suggestions.isEmpty) {
      return const SizedBox.shrink();
    } else {
      final ColorScheme colorScheme = Theme.of(context).colorScheme;

      return AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget? child) {
          return ClipRect(
            child: Align(
              heightFactor: _heightFactorAnimation.value,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Divider(
                    height: 1,
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  for (int i = 0; i < widget.suggestions.length; i++)
                    _SuggestionTile(
                      suggestion: widget.suggestions[i],
                      onTap: () =>
                          _handleCityTap(context, widget.suggestions[i].name),
                      isLast: i == widget.suggestions.length - 1,
                    ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _handleCityTap(BuildContext context, String cityName) {
    widget.textEditingController.text = cityName;
    context.read<SearchBloc>().add(SearchLocation(cityName));
  }
}

/// Individual suggestion tile with hover effects.
class _SuggestionTile extends StatefulWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.onTap,
    required this.isLast,
  });

  final QuickCitySuggestion suggestion;
  final VoidCallback onTap;
  final bool isLast;

  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered
            ? colorScheme.onSurface.withValues(alpha: 0.08)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 14.0,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  widget.suggestion.flag,
                  style: const TextStyle(fontSize: 20.0),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    widget.suggestion.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: _isHovered
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.north_west,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
