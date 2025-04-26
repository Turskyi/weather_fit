enum AppRoute {
  weather('/'),
  search('/search'),
  support('/support'),
  about('/about'),
  settings('/settings'),
  privacyPolicyAndroid('/privacy-policy-android'),
  privacyPolicy('/privacy-policy');

  const AppRoute(this.path);

  final String path;
}
