enum AppRoute {
  weather('/'),
  search('/search'),
  settings('/settings'),
  privacyPolicyAndroid('/privacy-policy-android'),
  privacyPolicy('/privacy-policy');

  const AppRoute(this.path);

  final String path;
}
