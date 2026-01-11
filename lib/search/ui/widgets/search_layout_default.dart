import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/extensions/build_context_extensions.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/res/widgets/leading_widget.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/widgets/keyboard_visibility_builder.dart';

class SearchLayoutDefault extends StatelessWidget {
  const SearchLayoutDefault({
    required this.textEditingController,
    required this.searchStateListener,
    required this.languageIsoCode,
    super.key,
  });

  final TextEditingController textEditingController;

  /// Takes the `BuildContext` along with the [bloc] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocWidgetListener<SearchState> searchStateListener;

  final String languageIsoCode;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: kIsWeb ? const LeadingWidget() : null,
        title: KeyboardVisibilityBuilder(
          builder: (bool isKeyboardVisible) {
            final Orientation orientation = MediaQuery.of(context).orientation;
            final bool isLandscapeOrientation =
                orientation == Orientation.landscape;
            return Text(
              isLandscapeOrientation && isKeyboardVisible
                  ? ''
                  : translate('search.page_app_bar_title'),
            );
          },
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16.0,
            children: <Widget>[
              const Spacer(flex: 1),
              Text(
                '🏙️',
                style: TextStyle(fontSize: textTheme.displayLarge?.fontSize),
              ),
              Text(
                translate('explore_weather_prompt'),
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                translate('search.instructions'),
                style: textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                constraints: BoxConstraints(maxWidth: context.maxWidth),
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    labelText: translate('search.city_or_country'),
                    hintText: translate('search.enter_city_or_country'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.all(12.0),
                  ),
                ),
              ),
              BlocConsumer<SearchBloc, SearchState>(
                listener: searchStateListener,
                builder: (BuildContext _, SearchState state) {
                  final double progressIndicatorSize = 20.0;
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: textEditingController,
                    child: state is SearchLoading
                        ? SizedBox(
                            height: progressIndicatorSize,
                            width: progressIndicatorSize,
                            child: const CircularProgressIndicator(),
                          )
                        : Text(
                            translate('submit'),
                            semanticsLabel: translate('submit'),
                          ),
                    builder:
                        (
                          BuildContext context,
                          TextEditingValue value,
                          Widget? textSubmit,
                        ) {
                          return ElevatedButton(
                            key: const Key('searchPage_search_iconButton'),
                            onPressed:
                                state is! SearchLoading &&
                                    value.text.trim().isNotEmpty
                                ? () {
                                    context.read<SearchBloc>().add(
                                      SearchLocation(value.text),
                                    );
                                  }
                                : null,
                            child: textSubmit,
                          );
                        },
                  );
                },
              ),
              const Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
