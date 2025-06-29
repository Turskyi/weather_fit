import 'package:intl/intl.dart';

String getPrivacyLastUpdatedDate(String locale) {
  return _formatDate(date: DateTime(2025, DateTime.june, 10), locale: locale);
}

String _formatDate({required DateTime date, required String locale}) {
  final DateFormat formatter = DateFormat('yMMMMd', locale);
  return formatter.format(date);
}
