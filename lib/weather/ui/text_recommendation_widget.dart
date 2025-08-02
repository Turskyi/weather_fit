import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';

import 'loading_outfit_text_widget.dart';

class TextRecommendationWidget extends StatelessWidget {
  const TextRecommendationWidget({required this.displayText, super.key});

  final String displayText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (BuildContext context, WeatherState state) {
        if (state is LoadingOutfitState) {
          return LoadingOutfitTextWidget(displayText: displayText);
        } else {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: SelectableText(
              displayText,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }
      },
    );
  }
}
