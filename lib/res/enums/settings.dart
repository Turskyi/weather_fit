enum Settings {
  languageIsoCode('language_iso_code'),
  location('saved_location'),
  savedPlans('saved_plans'),
  widgetUpdateFrequency('widget_update_frequency_minutes');

  const Settings(this.key);

  final String key;
}
