import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

String getPrivacyLastUpdatedDate(String locale) {
  return _formatDate(date: DateTime(2025, DateTime.june, 10), locale: locale);
}

String _formatDate({required DateTime date, required String locale}) {
  // Default format if locale-specific fails.
  const String defaultFormatPattern = 'yMMMMd';

  try {
    // Attempt to format with the provided `locale`.
    final DateFormat formatter = DateFormat(defaultFormatPattern, locale);
    return formatter.format(date);
  } catch (e, stackTrace) {
    // Log the error for debugging purposes.
    debugPrint(
      '_formatDate:\n'
      'Failed to format date with locale "$locale".\n'
      'Falling back to default non-localized format.\n'
      'Error: $e\n'
      'StackTrace: $stackTrace',
    );

    // Fallback to a non-localized format.
    final DateFormat fallbackFormatter = DateFormat(defaultFormatPattern);
    return fallbackFormatter.format(date);
  }
}
