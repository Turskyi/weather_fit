extension WeatherCodeToEmoji on int {
  String get toWeatherEmoji {
    switch (this) {
      case 0:
        return '☀️';
      case 1:
      case 2:
      case 3:
        return '⛅';
      case 45:
      case 48:
        return '🌫️';
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
      case 95:
      case 96:
      case 99:
        return '🌧️';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return '❄️';
      default:
        return '🤷';
    }
  }
}
