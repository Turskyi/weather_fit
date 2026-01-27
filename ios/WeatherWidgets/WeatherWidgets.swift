import SwiftUI
import UIKit
import WidgetKit

/// WeatherFit iOS Home Widget - Outfit Recommendation Display
///
/// **Architecture Overview:**
///
/// This widget displays:
/// 1. Current location and temperature
/// 2. Weather emoji and last update time
/// 3. Outfit recommendation text
/// 4. 3-hour forecast preview
/// 5. Outfit image with weather-appropriate background gradient
///
/// **Data Flow:**
/// ```
/// Flutter App (via home_widget plugin)
///   ↓
/// UserDefaults (app group: group.dmytrowidget)
///   ↓
/// Provider.getWeatherData()
///   ↓
/// WeatherWidgetsEntryView (UI rendering)
/// ```
///
/// **Image Loading with Graceful Fallback:**
///
/// The widget implements a 3-level fallback mechanism for outfit images:
/// ```
/// Level 1: Load from Flutter-provided path (freshly downloaded or cached file)
///   ↓ (fails if file missing/evicted)
/// Level 2: Load from bundled assets based on weather condition + temperature
///   ↓ (fails if bundled image not found)
/// Level 3: Render without image (gradient + text only)
/// ```
///
/// This is necessary because WidgetKit has strict constraints that can invalidate
/// cached file paths. See WidgetImageLoader for detailed explanation.
///
/// **iOS Background Updates:**
///
/// The app uses workmanager to schedule background updates, but iOS has fundamental
/// limitations on background task execution. See injector.dart for detailed explanation
/// of iOS constraints and why widget updates appear infrequent (~1x daily).
///
/// **Key Design Decisions:**
/// - Images are optional and decorative; missing images don't break the UI
/// - Widget degrades gracefully if data is unavailable
/// - All text labels include safe fallbacks (e.g., "Unknown Location")
/// - Error handling is silent (no alerts or logs that could break the widget)

// --- Data Models ---
struct ForecastItem: Codable, Hashable {
    let time: String
    let temperature: Double
    let weatherCode: Int
}

struct WeatherData: Codable {
    let emoji: String?
    let location: String?
    let temperature: String?
    let recommendation: String?
    let lastUpdated: String?
    let locale: String?
    let imagePath: String?
    let forecast: [ForecastItem]?
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let weatherData: WeatherData
}

// --- Timeline Provider ---
struct Provider: TimelineProvider {
    let appGroupIdentifier = "group.dmytrowidget"

    func getWeatherData() -> WeatherData? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("Could not load shared defaults.")
            return nil
        }

        let keys: [String: String] = [
            "emoji": "text_emoji",
            "location": "text_location",
            "temperature": "text_temperature",
            "recommendation": "text_recommendation",
            "lastUpdated": "text_last_updated",
            "imagePath": "image_weather",
            "forecastData": "forecast_data",
        ]

        let emoji = sharedDefaults.string(forKey: keys["emoji"]!)
        let location = sharedDefaults.string(forKey: keys["location"]!)
        let temperature = sharedDefaults.string(forKey: keys["temperature"]!)
        let recommendation = sharedDefaults.string(forKey: keys["recommendation"]!)
        let lastUpdated = sharedDefaults.string(forKey: keys["lastUpdated"]!)
        let imagePath = sharedDefaults.string(forKey: keys["imagePath"]!)
        let forecastDataString = sharedDefaults.string(forKey: keys["forecastData"]!)

        var forecast: [ForecastItem]?
        if let forecastDataString = forecastDataString,
            let data = forecastDataString.data(using: .utf8)
        {
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let forecastResponse = try decoder.decode([String: [ForecastItem]].self, from: data)
                forecast = forecastResponse["forecast"]
            } catch {
                print("WIDGET FORECAST DECODING FAILED: \(error)")
            }
        }

        let locale = sharedDefaults.string(forKey: "selected_language")

        return WeatherData(
            emoji: emoji,
            location: location,
            temperature: temperature,
            recommendation: recommendation,
            lastUpdated: lastUpdated,
            locale: locale,
            imagePath: imagePath,
            forecast: forecast,
        )
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), weatherData: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), weatherData: getWeatherData() ?? .placeholder)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, weatherData: getWeatherData() ?? .placeholder)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// --- SwiftUI Views ---

struct ForecastItemView: View {
    let item: ForecastItem
    let locale: String?

    var body: some View {
        VStack(spacing: 4) {
            Text(DateHelper.getDay(from: item.time, locale: locale ?? "en"))
                .font(.caption2).bold()
            Text(DateHelper.getTimeOfDay(from: item.time, locale: locale ?? "en"))
                .font(.caption)
            Text(WeatherHelper.getWeatherEmoji(for: item.weatherCode))
                .font(.title3)
            Text("\(Int(item.temperature.rounded()))°")
                .font(.caption)
        }
        .foregroundColor(.white)
        .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
    }
}

struct WeatherWidgetsEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 0) {
            // Top section: Aligned to corners to keep the center (faces) clear
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(entry.weatherData.location ?? "Unknown Location")
                        .font(.subheadline).fontWeight(.semibold)
                    Text(entry.weatherData.temperature ?? "--")
                        .font(.title2).fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(entry.weatherData.emoji ?? "")
                        .font(.largeTitle)
                    Text(entry.weatherData.lastUpdated ?? "")
                        .font(.system(size: 8))
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)

            Spacer()

            // Lower section: Recommendation and Forecast
            // Moved to the bottom to avoid covering the person's upper body/face
            VStack(spacing: 8) {
                if let recommendation = entry.weatherData.recommendation {
                    Text(recommendation)
                        .font(.caption).fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.25).cornerRadius(6))
                }

                // Forecast
                HStack(alignment: .bottom) {
                    if let forecast = entry.weatherData.forecast, !forecast.isEmpty {
                        ForEach(Array(forecast.enumerated()), id: \.element.time) { index, item in
                            ForecastItemView(item: item, locale: entry.weatherData.locale)
                            if index < forecast.count - 1 {
                                Spacer()
                            }
                        }
                    } else {
                        Text("No forecast data.").font(.caption)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
        }
        .widgetURL(URL(string: "weatherfit://open")!)
    }
}

// --- Widget Definition ---
struct WeatherWidgets: Widget {
    let kind: String = "WeatherWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetsEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    ZStack {
                        WeatherHelper.getGradient(
                            for: entry.weatherData.forecast?.first?.weatherCode ?? 0)

                        // Attempt to load outfit image with fallback mechanism.
                        // See WidgetImageLoader for detailed fallback strategy.
                        if let uiImage = WidgetImageLoader.loadOutfitImage(
                            imagePath: entry.weatherData.imagePath,
                            forecast: entry.weatherData.forecast
                        ) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        }
                        // If image fails to load, we gracefully degrade to just the gradient and text.
                        // This is expected behavior in WidgetKit when the image path becomes invalid.

                        // Added a subtle dark overlay to ensure text readability on light images
                        Color.black.opacity(0.2)
                    }
                }
        }
        .configurationDisplayName("WeatherFit")
        .description("Check the weather and outfit recommendation.")
    }
}

// --- Helpers & Extensions ---

/// Manages outfit image loading with a robust fallback mechanism.
///
/// **Why Images Disappear on iOS Widgets:**
///
/// WidgetKit has strict lifecycle constraints that can cause image paths to become invalid:
/// - File path is cached in UserDefaults and passed to the widget
/// - When the widget is refreshed (e.g., during background task), the file may have been deleted
/// - iOS may evict files from the app's document directory to free space
/// - Cached files are not guaranteed to persist across app lifecycle events
/// - If the app is killed while the widget is being updated, the file may be incomplete
///
/// **Our Fallback Strategy (Mirrors Flutter OutfitRepository):**
/// 1. **Primary**: Attempt to load from the provided file path (freshly downloaded image)
/// 2. **Fallback**: Parse weather condition from forecast and load bundled asset
/// 3. **Graceful degradation**: If all else fails, render without image (gradient + text)
///
/// This is similar to the Flutter-side logic:
/// ```
/// network → file → asset → fallback_asset
/// ```
///
/// By bundling a subset of outfit images, we ensure the widget always looks intentional,
/// never broken. The widget is decorative, so graceful degradation is acceptable.
///
struct WidgetImageLoader {
    /// Loads outfit image with multi-level fallback mechanism.
    ///
    /// - Parameter imagePath: Path to the cached image file from Flutter
    /// - Parameter forecast: Forecast data to determine weather condition
    /// - Returns: UIImage if available from any source, nil for graceful degradation
    static func loadOutfitImage(
        imagePath: String?,
        forecast: [ForecastItem]?
    ) -> UIImage? {
        // Level 1: Try to load from the provided file path (freshly downloaded or cached)
        if let imagePath = imagePath, let image = UIImage(contentsOfFile: imagePath) {
            return image
        }

        // Level 2: Fallback to bundled asset based on weather condition
        // Parse weather condition and temperature from the first forecast item
        if let forecast = forecast, !forecast.isEmpty {
            let weatherCode = forecast.first?.weatherCode ?? 0
            let temperature = Int(forecast.first?.temperature.rounded() ?? 0)

            // Determine condition name from weather code
            let conditionName = getConditionName(from: weatherCode)

            // Round temperature to nearest 10 for cleaner image names
            let roundedTemp = roundTemperatureToBucket(temperature)

            // Construct image name matching our bundled assets
            let fallbackImageName = "\(conditionName)_\(roundedTemp).png"

            // Try to load from bundle
            if let image = UIImage(named: fallbackImageName) {
                return image
            }
        }

        // Level 3: If even fallback fails, return nil to gracefully degrade to gradient + text
        return nil
    }

    /// Maps WMO weather codes to condition names matching Flutter's logic.
    private static func getConditionName(from weatherCode: Int) -> String {
        // Maps WMO codes to our image naming convention
        switch weatherCode {
        case 0: return "clear"
        case 1, 2, 3, 45, 48: return "cloudy"
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 85, 86:
            return "precipitation"
        default: return "clear"  // Default to clear if unknown
        }
    }

    /// Rounds temperature to the nearest bucket used in outfit images (±10°C increments).
    ///
    /// Examples:
    /// - 15°C → 10°C
    /// - 25°C → 20°C
    /// - 5°C → 0°C
    /// - -15°C → -20°C
    private static func roundTemperatureToBucket(_ temperature: Int) -> Int {
        let remainder = temperature % 10
        if remainder >= 5 {
            return temperature + (10 - remainder)
        } else if remainder <= -5 {
            return temperature - (10 + remainder)
        } else {
            return temperature - remainder
        }
    }
}

struct DateHelper {
    private static func parseDateTime(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return formatter.date(from: string)
    }

    static func getDay(from dateString: String, locale: String = "en") -> String {
        guard let date = parseDateTime(from: dateString) else {
            return ""
        }

        // Simple locale map for day labels.
        let isUk = locale.lowercased().hasPrefix("uk")
        let isPl = locale.lowercased().hasPrefix("pl")
        let isDe = locale.lowercased().hasPrefix("de")

        if Calendar.current.isDateInToday(date) {
            if isUk { return "Сьогодні" }
            if isPl { return "Dzisiaj" }
            if isDe { return "Heute" }
            return "Today"
        }
        if Calendar.current.isDateInTomorrow(date) {
            if isUk { return "Завтра" }
            if isPl { return "Jutro" }
            if isDe { return "Morgen" }
            return "Tomorrow"
        }
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        return dayFormatter.string(from: date)
    }

    static func getTimeOfDay(from dateString: String, locale: String) -> String {
        guard let date = parseDateTime(from: dateString) else {
            return ""
        }
        let hour = Calendar.current.component(.hour, from: date)

        // Simple locale map for time-of-day labels. Extend as needed.
        let isUk = locale.lowercased().hasPrefix("uk")
        let isPl = locale.lowercased().hasPrefix("pl")
        let isDe = locale.lowercased().hasPrefix("de")

        switch hour {
        case 5...11:
            if isUk { return "Ранок" }
            if isPl { return "Poranek" }
            if isDe { return "Morgen" }
            return "Morning"
        case 12...16:
            if isUk { return "Обід" }
            if isPl { return "Południe" }
            if isDe { return "Mittag" }
            return "Lunch"
        case 17...21:
            if isUk { return "Вечір" }
            if isPl { return "Wieczór" }
            if isDe { return "Abend" }
            return "Evening"
        default:
            if isUk { return "Ніч" }
            if isPl { return "Noc" }
            if isDe { return "Nacht" }
            return "Night"
        }
    }
}

struct WeatherHelper {
    static func getWeatherEmoji(for code: Int) -> String {
        switch code {
        case 0: return "☀️"
        case 1, 2, 3: return "☁️"
        case 45, 48: return "🌫"
        case 51, 53, 55, 56, 57: return "💧"
        case 61, 63, 65, 66, 67: return "🌧"
        case 71, 73, 75, 77: return "❄️"
        case 80, 81, 82: return "⛈"
        case 85, 86: return "🌨"
        case 95, 96, 99: return "🌪"
        default: return "🤔"
        }
    }

    static func getGradient(for code: Int) -> some View {
        let gradient: Gradient
        switch code {
        case 0:  // Sunny
            gradient = Gradient(colors: [
                Color(red: 1.0, green: 0.75, blue: 0.0), Color(red: 0.9, green: 0.45, blue: 0.0),
            ])
        case 1, 2, 3, 45, 48:  // Cloudy/Foggy
            gradient = Gradient(colors: [
                Color(red: 0.6, green: 0.7, blue: 0.8), Color(red: 0.4, green: 0.5, blue: 0.6),
            ])
        case 51...67, 80...82:  // Rain/Showers
            gradient = Gradient(colors: [
                Color(red: 0.3, green: 0.4, blue: 0.5), Color(red: 0.1, green: 0.2, blue: 0.3),
            ])
        case 71...77, 85, 86:  // Snow
            gradient = Gradient(colors: [Color(red: 0.8, green: 0.85, blue: 0.95), .gray])
        default:
            gradient = Gradient(colors: [.indigo, .purple])
        }
        return LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
    }
}

extension WeatherData {
    static var placeholder: WeatherData {
        .init(
            emoji: "☀️",
            location: "Cupertino",
            temperature: "24°C",
            recommendation: "A light jacket and jeans would be perfect for today.",
            lastUpdated: "just now",
            locale: "en",
            imagePath: nil,
            forecast: [
                .init(time: "2023-10-27T09:00", temperature: 18.0, weatherCode: 1),
                .init(time: "2023-10-27T13:00", temperature: 22.0, weatherCode: 0),
                .init(time: "2023-10-27T18:00", temperature: 19.0, weatherCode: 80),
            ]
        )
    }
}

// --- Preview ---
#Preview(as: .systemMedium) {
    WeatherWidgets()
} timeline: {
    SimpleEntry(date: .now, weatherData: .placeholder)
}
