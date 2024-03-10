enum AppRoute {
  weather('/'),
  search('/search'),
  settings('/settings'),
  privacyPolicyAndroid('/privacy-policy-android');

  const AppRoute(this.path);

  final String path;
}
