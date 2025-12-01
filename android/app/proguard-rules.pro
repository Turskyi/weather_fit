# Flutter's default ProGuard rules can be found in
# flutter/packages/flutter_tools/gradle/flutter_proguard_rules.pro.

# Keep the data classes used for JSON parsing by Gson in the WeatherWidget.
# R8, in release mode, can strip or obfuscate these classes because they are only
# accessed via reflection, causing a ClassCastException at runtime.
-keep class com.turskyi.weather_fit.ForecastItem { *; }
-keep class com.turskyi.weather_fit.ForecastData { *; }
