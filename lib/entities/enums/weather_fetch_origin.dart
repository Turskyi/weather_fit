enum WeatherFetchOrigin {
  // phone/tablet/anything that supports the widget.
  defaultDevice,
  // skip widget update.
  wearable;

  bool get isNotWearable => this != wearable;

  bool get isWearable => this == wearable;
}
