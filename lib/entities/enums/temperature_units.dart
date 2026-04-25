enum TemperatureUnits {
  fahrenheit,
  celsius;

  bool get isFahrenheit => this == TemperatureUnits.fahrenheit;

  bool get isCelsius => this == TemperatureUnits.celsius;

  String get unitSymbol => isCelsius ? 'C' : 'F';
}
