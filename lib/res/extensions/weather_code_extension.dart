extension WeatherCodeToEmoji on int {
  String get toWeatherEmoji {
    // WMO (Open-Meteo) codes: 0-99
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
        return '🌧️';
      case 95:
      case 96:
      case 99:
        return '⛈️';
      case 71:
      case 73:
      case 75:
      case 77:
        return '❄️';
      case 85:
      case 86:
        return '🌨️';
    }

    // OpenWeatherMap codes: 200-804
    if (this >= 200 && this < 600) {
      return '🌧️'; // Thunderstorm, Drizzle, Rain
    } else if (this >= 600 && this < 700) {
      return '❄️'; // Snow
    } else if (this >= 700 && this < 800) {
      return '🌫️'; // Atmosphere (Mist, Smoke, Haze, etc.)
    } else if (this == 800) {
      return '☀️'; // Clear
    } else if (this > 800 && this < 900) {
      return '☁️'; // Clouds (801, 802, 803, 804)
    }

    return '';
  }
}
