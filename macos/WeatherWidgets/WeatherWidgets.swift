import AppKit
import SwiftUI
import WidgetKit

// Typealias UIImage to NSImage for cross-platform compatibility in the loader logic
typealias UIImage = NSImage

/// WeatherFit macOS Home Widget - Outfit Recommendation Display
/// (Aligned with iOS implementation)
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

struct OpenMeteoResponse: Decodable {
    let current: CurrentWeather
    let hourly: HourlyForecast
}

struct CurrentWeather: Decodable {
    let temperature2m: Double
    let weatherCode: Int

    enum CodingKeys: String, CodingKey {
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
    }
}

struct HourlyForecast: Decodable {
    let time: [String]
    let temperature2m: [Double]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
    }
}

// --- Timeline Provider ---
/// The `TimelineProvider` is the engine of the widget.
/// It is responsible for:
/// 1. **Providing a placeholder**: A static preview shown while the widget is loading.
/// 2. **Providing a snapshot**: A single entry to show in the widget gallery.
/// 3. **Generating a timeline**: A series of entries that tell the system when to update the widget.
///
/// In this implementation, the timeline is updated every 15 minutes to fetch the latest weather data
/// from the shared `UserDefaults` (populated by the Flutter app).
struct Provider: TimelineProvider {
    let appGroupIdentifier = "group.dmytrowidget"
    private let latitudeKey = "weatherfit_location_latitude"
    private let longitudeKey = "weatherfit_location_longitude"
    private let temperatureUnitKey = "weatherfit_temperature_unit"
    private let updateFrequencyKey = "weatherfit_widget_update_frequency"

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
            forecast: forecast
        )
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), weatherData: .placeholder)
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> Void
    ) {
        refreshWeatherDataFromNetworkIfPossible { weatherData in
            let entry = SimpleEntry(
                date: Date(),
                weatherData: weatherData ?? self.getWeatherData() ?? .placeholder
            )
            completion(entry)
        }
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> Void
    ) {
        let currentDate = Date()
        refreshWeatherDataFromNetworkIfPossible { weatherData in
            let entry = SimpleEntry(
                date: currentDate,
                weatherData: weatherData ?? self.getWeatherData() ?? .placeholder
            )
            let nextUpdate = Calendar.current.date(
                byAdding: .minute,
                value: refreshIntervalMinutes(),
                to: currentDate
            )!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func refreshWeatherDataFromNetworkIfPossible(
        completion: @escaping (WeatherData?) -> Void
    ) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        else {
            completion(nil)
            return
        }

        guard
            let latitude = sharedDefaults.object(forKey: latitudeKey) as? Double,
            let longitude = sharedDefaults.object(forKey: longitudeKey) as? Double
        else {
            completion(nil)
            return
        }

        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code"),
            URLQueryItem(name: "hourly", value: "temperature_2m,weather_code"),
            URLQueryItem(name: "forecast_days", value: "2"),
            URLQueryItem(name: "timezone", value: "auto"),
        ]

        guard let url = components?.url else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Widget network fetch failed: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)

                let temperatureUnit =
                    sharedDefaults.string(forKey: self.temperatureUnitKey) ?? "celsius"
                let isFahrenheit = temperatureUnit == "fahrenheit"

                let formattedTemperature = self.formatTemperature(
                    celsiusValue: response.current.temperature2m,
                    isFahrenheit: isFahrenheit
                )

                let forecast = self.buildWidgetForecast(
                    from: response.hourly,
                    isFahrenheit: isFahrenheit
                )

                let locale = sharedDefaults.string(forKey: "selected_language")
                let updatedData = WeatherData(
                    emoji: WeatherHelper.getWeatherEmoji(for: response.current.weatherCode),
                    location: sharedDefaults.string(forKey: "text_location"),
                    temperature: formattedTemperature,
                    recommendation: sharedDefaults.string(forKey: "weatherfit_text_recommendation"),
                    lastUpdated: self.lastUpdatedText(),
                    locale: locale,
                    imagePath: sharedDefaults.string(forKey: "image_weather"),
                    forecast: forecast
                )

                sharedDefaults.set(updatedData.emoji, forKey: "weatherfit_text_emoji")
                sharedDefaults.set(updatedData.temperature, forKey: "text_temperature")
                sharedDefaults.set(updatedData.lastUpdated, forKey: "weatherfit_text_last_updated")
                if let forecastJson = self.encodeForecast(forecast) {
                    sharedDefaults.set(forecastJson, forKey: "forecast_data")
                }

                completion(updatedData)
            } catch {
                print("Widget response decode failed: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }

    private func buildWidgetForecast(
        from hourly: HourlyForecast,
        isFahrenheit: Bool
    ) -> [ForecastItem] {
        let count = min(
            hourly.time.count,
            min(hourly.temperature2m.count, hourly.weatherCode.count)
        )
        guard count > 0 else { return [] }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"

        let now = Date()
        var futureItems: [ForecastItem] = []

        for index in 0..<count {
            let timeString = hourly.time[index]
            guard let date = formatter.date(from: timeString), date > now else {
                continue
            }

            let celsius = hourly.temperature2m[index]
            let temperature = isFahrenheit ? (celsius * 9 / 5) + 32 : celsius
            let weatherCode = hourly.weatherCode[index]

            futureItems.append(
                ForecastItem(
                    time: timeString,
                    temperature: temperature,
                    weatherCode: weatherCode
                )
            )
        }

        let morning = futureItems.first { item in
            guard let date = formatter.date(from: item.time) else { return false }
            let hour = Calendar.current.component(.hour, from: date)
            return (8...11).contains(hour)
        }

        let lunch = futureItems.first { item in
            guard let date = formatter.date(from: item.time) else { return false }
            let hour = Calendar.current.component(.hour, from: date)
            return (12...15).contains(hour)
        }

        let evening = futureItems.first { item in
            guard let date = formatter.date(from: item.time) else { return false }
            let hour = Calendar.current.component(.hour, from: date)
            return (17...20).contains(hour)
        }

        let result = [morning, lunch, evening].compactMap { $0 }
        return result.sorted { $0.time < $1.time }
    }

    private func formatTemperature(celsiusValue: Double, isFahrenheit: Bool) -> String {
        let value = isFahrenheit ? ((celsiusValue * 9 / 5) + 32) : celsiusValue
        let rounded = Int(value.rounded())
        return "\(rounded)°\(isFahrenheit ? "F" : "C")"
    }

    private func lastUpdatedText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    private func encodeForecast(_ forecast: [ForecastItem]) -> String? {
        do {
            let data = try JSONEncoder().encode(["forecast": forecast])
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to encode widget forecast: \(error)")
            return nil
        }
    }

    private func refreshIntervalMinutes() -> Int {
        guard
            let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier),
            let minutes = sharedDefaults.object(forKey: updateFrequencyKey) as? Int,
            minutes > 0
        else {
            return 15
        }
        return max(15, minutes)
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
        // Horizontal layout for wide widgets (Medium)
        // macOS systemLarge is vertical to match iOS Large alignment
        let isWide = family == .systemMedium

        Group {
            if isWide {
                HStack(alignment: .top, spacing: 12) {
                    // Left Column: Image and Recommendation
                    VStack(alignment: .center, spacing: 8) {
                        imageSection
                        recommendationSection
                    }
                    .frame(maxWidth: .infinity)

                    // Right Column: Header and Forecast
                    VStack(alignment: .leading, spacing: 12) {
                        headerSection
                        forecastSection
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                // Vertical layout for Small and Large widgets
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
        .widgetURL(URL(string: "weatherfit://open")!)
    }

    /// The Outfit Image section with rounded corners
    private var imageSection: some View {
        Group {
            if let nsImage = WidgetImageLoader.loadOutfitImage(
                imagePath: entry.weatherData.imagePath,
                forecast: entry.weatherData.forecast
            ) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Recommendation text
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
            ZStack {
                WeatherHelper.getGradient(
                    for: entry.weatherData.forecast?.first?.weatherCode ?? 0
                )

                WeatherWidgetsEntryView(entry: entry)
                    .padding(8)
            }
            .containerBackground(for: .widget) {
                WeatherHelper.getGradient(
                    for: entry.weatherData.forecast?.first?.weatherCode ?? 0
                )
            }
            .clipShape(ContainerRelativeShape())
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
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
        case 0: return "clear"
        case 1, 2, 3, 45, 48: return "cloudy"
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 85, 86:
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
                Color(red: 1.0, green: 0.75, blue: 0.0),
                Color(red: 0.9, green: 0.45, blue: 0.0),
            ])
        case 1, 2, 3, 45, 48:  // Cloudy/Foggy
            gradient = Gradient(colors: [
                Color(red: 0.6, green: 0.7, blue: 0.8),
                Color(red: 0.4, green: 0.5, blue: 0.6),
            ])
        case 51...67, 80...82:  // Rain/Showers
            gradient = Gradient(colors: [
                Color(red: 0.3, green: 0.4, blue: 0.5),
                Color(red: 0.1, green: 0.2, blue: 0.3),
            ])
        case 71...77, 85, 86:  // Snow
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
