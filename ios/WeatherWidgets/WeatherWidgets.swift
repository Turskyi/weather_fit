import SwiftUI
import UIKit
import WidgetKit

/**
-------------------------------------------------------------------------------
⚠️  iOS WidgetKit: Why Widgets Cannot Independently Fetch Weather Data ⚠️
-------------------------------------------------------------------------------

**Key Limitation:**
    - WidgetKit extensions are sandboxed and cannot perform arbitrary background fetches or schedule their own updates.
    - All widget timeline updates are strictly controlled by iOS. The system decides when (and if) your widget code runs.

**What This Means:**
    - You CANNOT bypass iOS background execution limits by moving weather fetching logic into the widget extension.
    - The widget can only display data that was previously fetched and stored by the main app (using Workmanager or foreground fetch).
    - Even if you try to fetch data in the widget's timeline provider, iOS may throttle, delay, or skip your reload requests.
    - WidgetKit does not allow timers, polling, or persistent background execution.

**Best Practice:**
    - Always fetch and store weather data in the main app (background or foreground), then read it in the widget.
    - In the widget, check the last update timestamp and display a “stale” indicator if needed.
    - Accept that widgets may show stale data if iOS skips background updates—this is an OS-level limitation, not a code bug.

**References:**
    - Apple WidgetKit documentation: https://developer.apple.com/documentation/widgetkit
    - Apple Forums: https://developer.apple.com/forums/thread/651795
    - WidgetKit best practices: https://developer.apple.com/videos/play/wwdc2020/10028/

-------------------------------------------------------------------------------
*/

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
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        else {
            print("Could not load shared defaults.")
            return nil
        }

        let keys: [String: String] = [
            "location": "text_location",
            "temperature": "text_temperature",
            "imagePath": "image_weather",
            "forecastData": "forecast_data",
            "emoji": "weatherfit_text_emoji",
            "recommendation": "weatherfit_text_recommendation",
            "lastUpdated": "weatherfit_text_last_updated",
        ]

        let emoji = sharedDefaults.string(forKey: keys["emoji"]!)
        let location = sharedDefaults.string(forKey: keys["location"]!)
        let temperature = sharedDefaults.string(forKey: keys["temperature"]!)
        let recommendation = sharedDefaults.string(
            forKey: keys["recommendation"]!
        )
        let lastUpdated = sharedDefaults.string(forKey: keys["lastUpdated"]!)
        let imagePath = sharedDefaults.string(forKey: keys["imagePath"]!)
        let forecastDataString = sharedDefaults.string(
            forKey: keys["forecastData"]!
        )

        var forecast: [ForecastItem]?
        if let forecastDataString = forecastDataString,
            let data = forecastDataString.data(using: .utf8)
        {
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let forecastResponse = try decoder.decode(
                    [String: [ForecastItem]].self,
                    from: data
                )
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

    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> Void
    ) {
        let entry = SimpleEntry(
            date: Date(),
            weatherData: getWeatherData() ?? .placeholder
        )
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> Void
    ) {
        let currentDate = Date()
        let entry = SimpleEntry(
            date: currentDate,
            weatherData: getWeatherData() ?? .placeholder
        )
        let nextUpdate = Calendar.current.date(
            byAdding: .minute,
            value: 15,
            to: currentDate
        )!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// --- SwiftUI Views ---

struct ForecastItemView: View {
    let item: ForecastItem
    let locale: String?

    var body: some View {
        VStack(spacing: 2) {
            Text(DateHelper.getDay(from: item.time, locale: locale ?? "en"))
                .font(.system(size: 8, weight: .bold))
            Text(
                DateHelper.getTimeOfDay(from: item.time, locale: locale ?? "en")
            )
            .font(.system(size: 8))
            Text(WeatherHelper.getWeatherEmoji(for: item.weatherCode))
                .font(.title3)
            Text("\(Int(item.temperature.rounded()))°")
                .font(.system(size: 9, weight: .medium))
        }
        .foregroundColor(.white)
    }
}

struct WeatherWidgetsEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        // Horizontal layout for wide widgets (Medium, ExtraLarge)
        let isWide = family == .systemMedium || family == .systemExtraLarge

        Group {
            if isWide {
                HStack(alignment: .top, spacing: 12) {
                    // Left Column: Image and Recommendation (kept together as requested)
                    VStack(alignment: .center, spacing: 8) {
                        imageSection
                        recommendationSection
                    }
                    .frame(maxWidth: .infinity)

                    // Right Column: Header [location, temp, emoji, updated] and Forecast
                    VStack(alignment: .leading, spacing: 12) {
                        headerSection
                        forecastSection
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                // Vertical layout for Small and Large widgets
                // Image -> Recommendation -> Header -> Forecast
                VStack(spacing: 8) {
                    headerSection

                    imageSection
                        .frame(maxHeight: .infinity)

                    recommendationSection

                    if family != .systemSmall {
                        forecastSection
                    }
                }
            }
        }
        // Paddings surrounding the widget removed completely as requested
        .widgetURL(URL(string: "weatherfit://open")!)
    }

    /// The Outfit Image section with rounded corners
    private var imageSection: some View {
        Group {
            if let uiImage = WidgetImageLoader.loadOutfitImage(
                imagePath: entry.weatherData.imagePath,
                forecast: entry.weatherData.forecast
            ) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))  // Rounded corners for outfit image
            } else {
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Recommendation text - now placed right below the image
    private var recommendationSection: some View {
        Group {
            if let recommendation = entry.weatherData.recommendation {
                Text(recommendation)
                    .font(.system(size: 9, weight: .medium))
                    .multilineTextAlignment(.center)
                    .lineLimit(family == .systemSmall ? 2 : 4)
                    .padding(8)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
    }

    /// Header components: [location, temperature], [emoji, last updated]
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text(entry.weatherData.location ?? "Unknown")
                    .font(.system(size: 10, weight: .semibold))
                Text(entry.weatherData.temperature ?? "--°")
                    .font(.system(size: 16, weight: .bold))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 0) {
                Text(entry.weatherData.emoji ?? "☀️")
                    .font(.system(size: 18))
                Text(entry.weatherData.lastUpdated ?? "")
                    .font(.system(size: 7))
                    .opacity(0.8)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
        .foregroundColor(.white)
    }

    /// Forecast components (three parts)
    private var forecastSection: some View {
        Group {
            if let forecast = entry.weatherData.forecast, !forecast.isEmpty {
                HStack(spacing: 12) {
                    ForEach(forecast.prefix(3), id: \.self) { item in
                        ForecastItemView(
                            item: item,
                            locale: entry.weatherData.locale
                        )
                    }
                }
                .padding(10)
                .background(Color.black.opacity(0.2))
                .cornerRadius(12)
                .foregroundColor(.white)
            }
        }
    }
}

// --- Widget Definition ---
struct WeatherWidgets: Widget {
    let kind: String = "WeatherWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetsEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    WeatherHelper.getGradient(
                        for: entry.weatherData.forecast?.first?.weatherCode ?? 0
                    )
                }
        }
        .configurationDisplayName("WeatherFit")
        .description("Check the weather and outfit recommendation.")
    }
}

// --- Helpers & Extensions ---

struct WidgetImageLoader {
    static func loadOutfitImage(
        imagePath: String?,
        forecast: [ForecastItem]?
    ) -> UIImage? {
        if let imagePath = imagePath,
            let image = UIImage(contentsOfFile: imagePath)
        {
            return image
        }

        if let forecast = forecast, !forecast.isEmpty {
            let weatherCode = forecast.first?.weatherCode ?? 0
            let temperature = Int(forecast.first?.temperature.rounded() ?? 0)
            let conditionName = getConditionName(from: weatherCode)
            let roundedTemp = roundTemperatureToBucket(temperature)
            let fallbackImageName = "\(conditionName)_\(roundedTemp).png"

            if let image = UIImage(named: fallbackImageName) {
                return image
            }
        }
        return nil
    }

    private static func getConditionName(from weatherCode: Int) -> String {
        switch weatherCode {
        case 0, 800: return "clear"
        case 1, 2, 3, 45, 48, 701...799, 801...804: return "cloudy"
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 85, 86, 95, 96, 99, 200...599, 600...699:
            return "precipitation"
        default: return "clear"
        }
    }

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

        let isUk = locale.lowercased().hasPrefix("uk")
        let isPl = locale.lowercased().hasPrefix("pl")
        let isDe = locale.lowercased().hasPrefix("de")

        if Calendar.current.isDateInToday(date) {
            if isUk {
                return "Сьогодні"
            }
            if isPl {
                return "Dzisiaj"
            }
            if isDe {
                return "Heute"
            }
            return "Today"
        }
        if Calendar.current.isDateInTomorrow(date) {
            if isUk {
                return "Завтра"
            }
            if isPl {
                return "Jutro"
            }
            if isDe {
                return "Morgen"
            }
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

        let isUk = locale.lowercased().hasPrefix("uk")
        let isPl = locale.lowercased().hasPrefix("pl")
        let isDe = locale.lowercased().hasPrefix("de")

        switch hour {
        case 5...11:
            if isUk {
                return "Ранок"
            }
            if isPl {
                return "Poranek"
            }
            if isDe {
                return "Morgen"
            }
            return "Morning"
        case 12...16:
            if isUk {
                return "Обід"
            }
            if isPl {
                return "Południe"
            }
            if isDe {
                return "Mittag"
            }
            return "Lunch"
        case 17...21:
            if isUk {
                return "Вечір"
            }
            if isPl {
                return "Wieczór"
            }
            if isDe {
                return "Abend"
            }
            return "Evening"
        default:
            if isUk {
                return "Ніч"
            }
            if isPl {
                return "Noc"
            }
            if isDe {
                return "Nacht"
            }
            return "Night"
        }
    }
}

struct WeatherHelper {
    static func getWeatherEmoji(for code: Int) -> String {
        switch code {
        case 0, 800: return "☀️"
        case 1, 2, 3, 801...804: return "☁️"
        case 45, 48, 701...799: return "🌫"
        case 51, 53, 55, 56, 57, 200...599: return "🌧"
        case 61, 63, 65, 66, 67: return "🌧"
        case 71, 73, 75, 77, 600...699: return "❄️"
        case 80, 81, 82: return "⛈"
        case 85, 86: return "🌨"
        case 95, 96, 99: return "🌪"
        default: return ""
        }
    }

    static func getGradient(for code: Int) -> some View {
        let gradient: Gradient
        switch code {
        case 0, 800:  // Sunny
            gradient = Gradient(colors: [
                Color(red: 1.0, green: 0.75, blue: 0.0),
                Color(red: 0.9, green: 0.45, blue: 0.0),
            ])
        case 1, 2, 3, 45, 48, 701...799, 801...804:  // Cloudy/Foggy
            gradient = Gradient(colors: [
                Color(red: 0.6, green: 0.7, blue: 0.8),
                Color(red: 0.4, green: 0.5, blue: 0.6),
            ])
        case 51...67, 80...82, 95...99, 200...599:  // Rain/Showers
            gradient = Gradient(colors: [
                Color(red: 0.3, green: 0.4, blue: 0.5),
                Color(red: 0.1, green: 0.2, blue: 0.3),
            ])
        case 71...77, 85, 86, 600...699:  // Snow
            gradient = Gradient(colors: [
                Color(red: 0.8, green: 0.85, blue: 0.95), .gray,
            ])
        default:
            gradient = Gradient(colors: [.indigo, .purple])
        }
        return LinearGradient(
            gradient: gradient,
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension WeatherData {
    static var placeholder: WeatherData {
        .init(
            emoji: "☀️",
            location: "Cupertino",
            temperature: "24°C",
            recommendation:
                "A light jacket and jeans would be perfect for today.",
            lastUpdated: "just now",
            locale: "en",
            imagePath: nil,
            forecast: [
                .init(
                    time: "2023-10-27T09:00",
                    temperature: 18.0,
                    weatherCode: 1
                ),
                .init(
                    time: "2023-10-27T13:00",
                    temperature: 22.0,
                    weatherCode: 0
                ),
                .init(
                    time: "2023-10-27T18:00",
                    temperature: 19.0,
                    weatherCode: 80
                ),
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
