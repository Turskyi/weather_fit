import 'package:flutter/material.dart';
import 'package:weather_fit/res/widgets/background.dart';

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
                  const Text('🏙️', style: TextStyle(fontSize: 64)),
                  Text(
                    'Let\'s explore the weather! ',
                    style: textTheme.headlineMedium,
                  ),
                  Text(
                    'Type the city or country name and tap "Submit"\nto see the'
                    ' weather.',
                    style: textTheme.titleSmall,
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
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _textController,
                    child: const Text('Submit', semanticsLabel: 'Submit'),
                    builder: (
                      BuildContext context,
                      TextEditingValue value,
                      Widget? textSubmit,
                    ) {
                      return ElevatedButton(
                        key: const Key('searchPage_search_iconButton'),
                        onPressed: value.text.trim().isNotEmpty
                            ? () => Navigator.of(context).pop(_text)
                            : null,
                        child: textSubmit,
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
}
