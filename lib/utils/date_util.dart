import 'package:intl/intl.dart';

String get kPrivacyLastUpdatedDate => _formatDate(
      DateTime(2025, DateTime.june, 10),
    );

String _formatDate(DateTime date) {
  final DateFormat formatter = DateFormat('yMMMMd');
  return formatter.format(date);
}
