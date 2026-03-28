enum Settings {
  languageIsoCode('language_iso_code'),
  location('saved_location'),
  lastSearchedLocation('last_searched_location'),
  savedPlans('saved_plans'),
  favourites('favourites'),
  widgetUpdateFrequency('widget_update_frequency_minutes'),
  dayStartHour('day_start_hour'),
  nightStartHour('night_start_hour');

  const Settings(this.key);

  final String key;
}
