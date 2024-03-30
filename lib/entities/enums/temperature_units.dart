enum TemperatureUnits {
  fahrenheit,
  celsius;

  bool get isFahrenheit => this == TemperatureUnits.fahrenheit;

  bool get isCelsius => this == TemperatureUnits.celsius;
}
