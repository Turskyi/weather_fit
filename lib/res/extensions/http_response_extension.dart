import 'dart:io';

import 'package:http/http.dart';

/// Extension to add utility getters to [Response].
extension HttpResponseExtension on Response {
  /// Returns true if the status code is 200 (OK).
  bool get isOk => statusCode == HttpStatus.ok;

  /// Returns true if the status code is in the 2xx range.
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
