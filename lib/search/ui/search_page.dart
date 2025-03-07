import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _textController = TextEditingController();

  String get _text => _textController.text.trim();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: 'City or country search page',
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(title: const Text('City or country search')),
        body: Stack(
          children: <Widget>[
            const Background(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '🏙️',
                    style: TextStyle(
                      fontSize: textTheme.displayLarge?.fontSize,
                    ),
                  ),
                  Text(
                    'Let\'s explore the weather! ',
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Type the city or country name and tap "Submit" to see the'
                    ' weather.',
                    style: textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: 'City or country',
                      hintText: 'Enter city or country name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.all(12.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  BlocConsumer<SearchBloc, SearchState>(
                    listener: (BuildContext context, SearchState state) {
                      if (state is SearchLocationFound) {
                        _showLocationConfirmationDialog(state.location);
                      } else if (state is SearchWeatherLoaded) {
                        // Navigate to the weather details page.
                        Navigator.pop(context, state.weather);
                      } else if (state is SearchError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage)),
                        );
                      }
                    },
                    builder: (BuildContext context, SearchState state) {
                      return ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _textController,
                        child: state is SearchLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Submit', semanticsLabel: 'Submit'),
                        builder: (
                          BuildContext context,
                          TextEditingValue value,
                          Widget? textSubmit,
                        ) {
                          return SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              key: const Key('searchPage_search_iconButton'),
                              onPressed: state is! SearchLoading &&
                                      value.text.trim().isNotEmpty
                                  ? () => context
                                      .read<SearchBloc>()
                                      .add(SearchLocation(_text))
                                  : null,
                              child: textSubmit,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _showLocationConfirmationDialog(Location location) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Is this your location?'),
          content: Text(
            '${location.name}, ${location.province}, ${location.country}',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                _showLocationIcon();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<SearchBloc>().add(ConfirmLocation(location));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLocationIcon() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Use your current location?'),
          content: const Text(
            'We couldn\'t find the correct location. Would you like to use '
            'your current location instead?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();

                context.read<SearchBloc>().add(
                      const RequestPermissionAndSearchByLocation(),
                    );
              },
            ),
          ],
        );
      },
    );
  }
}
