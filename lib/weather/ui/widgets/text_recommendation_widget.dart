import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/weather/bloc/weather_bloc.dart';

import 'loading_outfit_text_widget.dart';

class TextRecommendationWidget extends StatelessWidget {
  const TextRecommendationWidget({required this.displayText, super.key});

  final String displayText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isExtraSmall = context.isExtraSmallScreen;

    final TextStyle? textStyle = isExtraSmall
        ? theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            height: 1.3,
          )
        : theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            height: 1.5,
          );

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
            padding: EdgeInsets.all(isExtraSmall ? 10 : 20),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: SelectableText(
                displayText,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
      },
    );
  }
}
