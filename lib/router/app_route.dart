enum AppRoute {
  weather('/'),
  search('/search'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}
