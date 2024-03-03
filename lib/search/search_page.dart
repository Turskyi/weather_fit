import 'package:flutter/material.dart';
import 'package:weather_fit/weather/ui/weather.dart';

class SearchPage extends StatefulWidget {
  const SearchPage._();

  static Route<String> route() {
    return MaterialPageRoute<String>(builder: (_) => const SearchPage._());
  }

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _textController = TextEditingController();

  String get _text => _textController.text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('City Search')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      hintText: 'Toronto',
                    ),
                  ),
                ),
              ),
              IconButton(
                key: const Key('searchPage_search_iconButton'),
                icon: const Icon(Icons.search, semanticLabel: 'Submit'),
                onPressed: () => Navigator.of(context).pop(_text),
              ),
            ],
          ),
          const WeatherEmpty(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
