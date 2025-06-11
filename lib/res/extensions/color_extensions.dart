import 'dart:ui';

extension ColorExtension on Color {
  Color brighten([int percent = 10]) {
    assert(
      1 <= percent && percent <= 100,
      'percentage must be between 1 and 100',
    );
    final double p = percent / 100;
    final int alpha = (a * 255).toInt();
    final int red = (r * 255).toInt();
    final int green = (g * 255).toInt();
    final int blue = (b * 255).toInt();
    return Color.fromARGB(
      alpha,
      red + ((255 - red) * p).round(),
      green + ((255 - green) * p).round(),
      blue + ((255 - blue) * p).round(),
    );
  }

  int get intAlpha => _floatToInt8(a);

  int get intRed => _floatToInt8(r);

  int get intGreen => _floatToInt8(g);

  int get intBlue => _floatToInt8(b);

  int _floatToInt8(double x) => (x * 255.0).round() & 0xff;
}
