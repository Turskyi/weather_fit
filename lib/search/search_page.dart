import 'package:flutter/material.dart';
import 'package:weather_fit/res/widgets/background.dart';
import 'package:weather_fit/weather/ui/weather.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _textController = TextEditingController();

  String get _text => _textController.text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'City search page',
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(title: const Text('City Search')),
        body: Stack(
          children: <Widget>[
            const Background(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const WeatherEmpty(),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      hintText: 'Enter city name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.all(12.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    key: const Key('searchPage_search_iconButton'),
                    child: const Text('Search', semanticsLabel: 'Submit'),
                    onPressed: () {
                      if (_text.isNotEmpty) {
                        Navigator.of(context).pop(_text);
                      }
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
}
