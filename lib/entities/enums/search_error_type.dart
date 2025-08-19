enum SearchErrorType {
  /// General network issues.
  network,
  locationNotFound,
  permissionDenied,
  permissionDeniedPermanently,

  /// For CERTIFICATE_VERIFY_FAILED.
  certificateValidationFailed,
  locationServiceDisabled,
  unknown;

  /// Returns `true` if the error is due to a certificate validation failure.
  bool get isCertificateValidationError =>
      this == SearchErrorType.certificateValidationFailed;

  /// Returns `true` if the error is due to permanently denied location
  /// permissions.
  bool get isPermissionDeniedPermanentlyError =>
      this == SearchErrorType.permissionDeniedPermanently;

  /// Returns `true` if the error is due to a network issue.
  bool get isNetworkError => this == SearchErrorType.network;
}
