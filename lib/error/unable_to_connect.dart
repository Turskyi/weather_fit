import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weather_fit/search/bloc/search_bloc.dart';
import 'package:weather_fit/settings/bloc/settings_bloc.dart';

class UnableToConnect extends StatelessWidget {
  const UnableToConnect({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final String searchQuery = args is SearchError ? args.query : '';
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('📡', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              translate('error.unable_to_connect_short'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (args is SearchError)
              ElevatedButton(
                onPressed: searchQuery.isEmpty
                    ? null
                    : () => _popAndSearch(context: context, text: searchQuery),
                child: Text(translate('try_again')),
              ),
            TextButton(
              onPressed: () => _handleReportActionAndPop(context),
              child: Text(translate('error.report_issue')),
            ),
          ],
        ),
      ),
    );
  }

  void _popAndSearch({required BuildContext context, required String text}) {
    Navigator.of(context).pop();
    context.read<SearchBloc>().add(SearchLocation(text));
  }

  void _handleReportActionAndPop(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    context.read<SettingsBloc>().add(
      BugReportPressedEvent(args is SearchError ? args.errorMessage : ''),
    );
    Navigator.of(context).pop();
  }
}
