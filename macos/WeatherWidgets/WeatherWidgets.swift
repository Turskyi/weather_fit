import AppKit
import SwiftUI
import WidgetKit
import os

private let widgetLog = Logger(
    subsystem: "com.turskyi.weatherFit.WeatherWidgets",
    category: "lifecycle"
)

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
    let isWeatherBackgroundEnabled: Bool
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
        widgetLog.debug("[getWeatherData] reading UserDefaults suite: \(appGroupIdentifier)")
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        else {
            widgetLog.error(
                "[getWeatherData] FAILED – cannot open UserDefaults suite \(appGroupIdentifier)")
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
                widgetLog.error(
                    "[getWeatherData] forecast decode error: \(error.localizedDescription)")
                print("WIDGET FORECAST DECODING FAILED: \(error)")
            }
        }

        let locale = sharedDefaults.string(forKey: "selected_language")
        let isWeatherBackgroundEnabled = sharedDefaults.bool(
            forKey: "weatherfit_is_weather_background_enabled"
        )
        widgetLog.debug(
            "[getWeatherData] result – location=\(location ?? "nil"), temp=\(temperature ?? "nil"), emoji=\(emoji ?? "nil"), imagePath=\(imagePath ?? "nil"), forecastItems=\(forecast?.count ?? 0), isWeatherBackgroundEnabled=\(isWeatherBackgroundEnabled)"
        )

        return WeatherData(
            emoji: emoji,
            location: location,
            temperature: temperature,
            recommendation: recommendation,
            lastUpdated: lastUpdated,
            locale: locale,
            imagePath: imagePath,
            forecast: forecast,
            isWeatherBackgroundEnabled: isWeatherBackgroundEnabled
        )
    }

    func placeholder(in context: Context) -> SimpleEntry {
        widgetLog.debug("[placeholder] called – returning static placeholder")
        return SimpleEntry(date: Date(), weatherData: .placeholder)
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> Void
    ) {
        widgetLog.debug("[getSnapshot] called – isPreview=\(context.isPreview)")
        refreshWeatherDataFromNetworkIfPossible { weatherData in
            let resolvedData = weatherData ?? self.getWeatherData() ?? .placeholder
            widgetLog.debug(
                "[getSnapshot] resolved – source=\(weatherData != nil ? "network" : "cache/placeholder"), location=\(resolvedData.location ?? "nil")"
            )
            let entry = SimpleEntry(
                date: Date(),
                weatherData: resolvedData
            )
            completion(entry)
        }
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> Void
    ) {
        widgetLog.debug("[getTimeline] called")
        let currentDate = Date()
        refreshWeatherDataFromNetworkIfPossible { weatherData in
            let resolvedData = weatherData ?? self.getWeatherData() ?? .placeholder
            let next = Calendar.current.date(
                byAdding: .minute,
                value: refreshIntervalMinutes(),
                to: currentDate
            )!
            widgetLog.debug(
                "[getTimeline] resolved – source=\(weatherData != nil ? "network" : "cache/placeholder"), location=\(resolvedData.location ?? "nil"), nextUpdate=\(next.description)"
            )
            let entry = SimpleEntry(
                date: currentDate,
                weatherData: resolvedData
            )
            let timeline = Timeline(entries: [entry], policy: .after(next))
            completion(timeline)
        }
    }

    private func refreshWeatherDataFromNetworkIfPossible(
        completion: @escaping (WeatherData?) -> Void
    ) {
        widgetLog.debug("[network] refreshWeatherDataFromNetworkIfPossible – start")
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        else {
            widgetLog.error("[network] FAILED – cannot open UserDefaults suite")
            completion(nil)
            return
        }

        guard
            let latitude = sharedDefaults.object(forKey: latitudeKey) as? Double,
            let longitude = sharedDefaults.object(forKey: longitudeKey) as? Double
        else {
            widgetLog.warning("[network] no lat/lon in UserDefaults – skipping network fetch")
            completion(nil)
            return
        }
        widgetLog.debug("[network] lat=\(latitude), lon=\(longitude)")

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

        widgetLog.debug("[network] requesting URL: \(url.absoluteString)")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                widgetLog.error("[network] fetch FAILED: \(error.localizedDescription)")
                print("Widget network fetch failed: \(error)")
                completion(nil)
                return
            }
            if let http = response as? HTTPURLResponse {
                widgetLog.debug("[network] HTTP status: \(http.statusCode)")
            }
            guard let data = data else {
                widgetLog.error("[network] response had no data")
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
                    lastUpdated: self.lastUpdatedText(locale: locale),
                    locale: locale,
                    imagePath: sharedDefaults.string(forKey: "image_weather"),
                    forecast: forecast,
                    isWeatherBackgroundEnabled: sharedDefaults.bool(
                        forKey: "weatherfit_is_weather_background_enabled"
                    )
                )

                sharedDefaults.set(updatedData.emoji, forKey: "weatherfit_text_emoji")
                sharedDefaults.set(updatedData.temperature, forKey: "text_temperature")
                sharedDefaults.set(updatedData.lastUpdated, forKey: "weatherfit_text_last_updated")
                if let forecastJson = self.encodeForecast(forecast) {
                    sharedDefaults.set(forecastJson, forKey: "forecast_data")
                }

                widgetLog.debug(
                    "[network] SUCCESS – temp=\(updatedData.temperature ?? "nil"), emoji=\(updatedData.emoji ?? "nil"), forecastItems=\(updatedData.forecast?.count ?? 0)"
                )
                completion(updatedData)
            } catch {
                widgetLog.error("[network] JSON decode FAILED: \(error.localizedDescription)")
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

    private func lastUpdatedText(locale: String? = nil) -> String {
        let formatter = DateFormatter()
        if let locale = locale {
            formatter.locale = Locale(identifier: locale)
        }
        formatter.setLocalizedDateFormatFromTemplate("MMM d, HH:mm")
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

    // Returns the widget refresh interval in minutes, as set by Flutter (UserDefaults),
    // or falls back to 30 minutes if not set or invalid.
    private func refreshIntervalMinutes() -> Int {
        guard
            let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier),
            let minutes = sharedDefaults.object(forKey: updateFrequencyKey) as? Int,
            minutes > 0
        else {
            return 30 // fallback to 30 minutes if not set or invalid
        }
        return max(30, minutes) // never less than 30 minutes
    }
}

// --- SwiftUI Views ---

struct ForecastItemView: View {
    let item: ForecastItem
    let locale: String?

    var body: some View {
        VStack(spacing: 2) {
            // Show full date and time on macOS
            Text(DateHelper.getDateAndTimeString(from: item.time, locale: locale ?? "en"))
                .font(.system(size: 9, weight: .bold))
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

        ZStack {
            if entry.weatherData.isWeatherBackgroundEnabled {
                WeatherBackgroundPattern(
                    emoji: entry.weatherData.emoji ?? "☀️",
                    isNight: DateHelper.isNight()
                )
            }

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
        }
        .widgetURL(URL(string: "weatherfit://open")!)
        .onAppear {
            widgetLog.debug(
                "[view] WeatherWidgetsEntryView appeared - family=\(family.debugDescription), location=\(entry.weatherData.location ?? "nil"), temp=\(entry.weatherData.temperature ?? "nil"), entryDate=\(entry.date.description)"
            )
        }
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
                Color.clear
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
            let weatherCode = entry.weatherData.forecast?.first?.weatherCode ?? 0
            let isNight = DateHelper.isNight()

            ZStack {
                WeatherHelper.getGradient(
                    for: weatherCode,
                    isNight: isNight
                )

                WeatherWidgetsEntryView(entry: entry)
                    .padding(8)
            }
            .containerBackground(for: .widget) {
                WeatherHelper.getGradient(
                    for: weatherCode,
                    isNight: isNight
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
    private static let appGroupIdentifier = "group.dmytrowidget"

    static func loadOutfitImage(
        imagePath: String?,
        forecast: [ForecastItem]?
    ) -> UIImage? {
        // Level 1: Load from the Flutter-provided path.
        if let imagePath = imagePath, !imagePath.isEmpty {
            if let image = UIImage(contentsOfFile: imagePath) {
                widgetLog.debug("[image] Level 1: loaded from path: \(imagePath)")
                return image
            } else {
                widgetLog.error("[image] Level 1 FAILED – cannot read file at: \(imagePath)")
            }
        } else {
            widgetLog.debug("[image] Level 1 skipped – imagePath is nil or empty")
        }

        // Level 2: Look in the shared app group container for outfit_image.png.
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) {
            let outfitURL = groupURL.appendingPathComponent("outfit_image.png")
            if let image = UIImage(contentsOfFile: outfitURL.path) {
                widgetLog.debug("[image] Level 2: loaded outfit_image.png from app group container")
                return image
            } else {
                widgetLog.debug("[image] Level 2: outfit_image.png not found at \(outfitURL.path)")
            }
        } else {
            widgetLog.error(
                "[image] Level 2 FAILED – cannot open app group container \(appGroupIdentifier)")
        }

        // Level 3: Load from bundled PNG by weather condition + rounded temperature.
        if let forecast = forecast, !forecast.isEmpty {
            let weatherCode = forecast.first?.weatherCode ?? 0
            let temperature = Int(forecast.first?.temperature.rounded() ?? 0)
            let conditionName = getConditionName(from: weatherCode)
            let roundedTemp = roundTemperatureToBucket(temperature)
            let fallbackImageName = "\(conditionName)_\(roundedTemp).png"

            if let image = UIImage(named: fallbackImageName) {
                widgetLog.debug("[image] Level 3: loaded bundled asset \(fallbackImageName)")
                return image
            } else {
                widgetLog.debug(
                    "[image] Level 3 FAILED – bundled asset not found: \(fallbackImageName)")
            }
        } else {
            widgetLog.debug("[image] Level 3 skipped – no forecast data")
        }

        widgetLog.error("[image] All fallbacks exhausted – no image available")
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
    static func isNight() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 6 || hour >= 21
    }

    private static func parseDateTime(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return formatter.date(from: string)
    }

    /// Returns a formatted date and time string, e.g. "Apr 12, 09:00"
    static func getDateAndTimeString(from dateString: String, locale: String = "en") -> String {
        guard let date = parseDateTime(from: dateString) else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale)
        formatter.setLocalizedDateFormatFromTemplate("MMM d, HH:mm")
        return formatter.string(from: date)
    }

    static func getDay(from dateString: String, locale: String = "en") -> String {
        guard let date = parseDateTime(from: dateString) else {
            return ""
        }

        let isUk = locale.lowercased().hasPrefix("uk")
        let isPl = locale.lowercased().hasPrefix("pl")
        let isDe = locale.lowercased().hasPrefix("de")
        let isNl = locale.lowercased().hasPrefix("nl")

        if Calendar.current.isDateInToday(date) {
            if isUk { return "Сьогодні" }
            if isPl { return "Dzisiaj" }
            if isDe { return "Heute" }
            if isNl { return "Vandaag" }
            return "Today"
        }
        if Calendar.current.isDateInTomorrow(date) {
            if isUk { return "Завтра" }
            if isPl { return "Jutro" }
            if isDe { return "Morgen" }
            if isNl { return "Morgen" }
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
        let isNl = locale.lowercased().hasPrefix("nl")

        switch hour {
        case 5...11:
            if isUk { return "Ранок" }
            if isPl { return "Poranek" }
            if isDe { return "Morgen" }
            if isNl { return "Ochtend" }
            return "Morning"
        case 12...16:
            if isUk { return "Обід" }
            if isPl { return "Południe" }
            if isDe { return "Mittag" }
            if isNl { return "Middag" }
            return "Lunch"
        case 17...21:
            if isUk { return "Вечір" }
            if isPl { return "Wieczór" }
            if isDe { return "Abend" }
            if isNl { return "Avond" }
            return "Evening"
        default:
            if isUk { return "Ніч" }
            if isPl { return "Noc" }
            if isDe { return "Nacht" }
            if isNl { return "Nacht" }
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
        case 80, 81, 82: return "🌧"
        case 85, 86: return "🌨"
        case 95, 96, 99: return "⛈"
        default: return ""
        }
    }

    static func getGradient(for code: Int, isNight: Bool) -> some View {
        let colors: [Color]
        switch code {
        case 0, 800:  // Sunny
            colors = isNight
                ? [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.02, green: 0.02, blue: 0.05),
                    Color(red: 0.0, green: 0.0, blue: 0.02)
                ]
                : [
                    Color(red: 1.0, green: 0.8, blue: 0.2),
                    Color(red: 1.0, green: 0.6, blue: 0.0),
                    Color(red: 0.9, green: 0.4, blue: 0.0),
                    Color(red: 0.8, green: 0.3, blue: 0.0)
                ]
        case 1, 2, 3, 45, 48, 701...799, 801...804:  // Cloudy/Foggy
            colors = isNight
                ? [
                    Color(red: 0.15, green: 0.15, blue: 0.2),
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.02, green: 0.02, blue: 0.05)
                ]
                : [
                    Color(red: 0.6, green: 0.7, blue: 0.8),
                    Color(red: 0.5, green: 0.6, blue: 0.7),
                    Color(red: 0.4, green: 0.5, blue: 0.6),
                    Color(red: 0.3, green: 0.4, blue: 0.5)
                ]
        case 51...67, 80...82, 95...99, 200...599:  // Rain/Showers
            colors = isNight
                ? [
                    Color(red: 0.1, green: 0.15, blue: 0.25),
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.02, green: 0.05, blue: 0.15),
                    Color(red: 0.0, green: 0.02, blue: 0.1)
                ]
                : [
                    Color(red: 0.3, green: 0.4, blue: 0.6),
                    Color(red: 0.2, green: 0.3, blue: 0.5),
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.05, green: 0.1, blue: 0.3)
                ]
        case 71...77, 85, 86, 600...699:  // Snow
            colors = isNight
                ? [
                    Color(red: 0.2, green: 0.2, blue: 0.3),
                    Color(red: 0.15, green: 0.15, blue: 0.25),
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.15)
                ]
                : [
                    Color(red: 0.85, green: 0.9, blue: 1.0),
                    Color(red: 0.75, green: 0.8, blue: 0.9),
                    Color(red: 0.65, green: 0.7, blue: 0.8),
                    Color(red: 0.55, green: 0.6, blue: 0.7)
                ]
        default:
            colors = isNight
                ? [
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.05, green: 0.02, blue: 0.15),
                    Color(red: 0.02, green: 0.01, blue: 0.1),
                    Color(red: 0.01, green: 0.0, blue: 0.05)
                ]
                : [Color.indigo, Color.purple, Color.blue, Color.cyan]
        }
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct WeatherBackgroundPattern: View {
    let emoji: String
    let isNight: Bool

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let columns = Int(size.width / 40) + 1
            let rows = Int(size.height / 40) + 1

            VStack(spacing: 20) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 20) {
                        ForEach(0..<columns, id: \.self) { column in
                            Text(emoji)
                                .font(.system(size: 20))
                                .opacity(isNight ? 0.07 : 0.15)
                                .rotationEffect(.degrees((row + column) % 2 == 0 ? 15 : -15))
                        }
                    }
                }
            }
            .frame(width: size.width, height: size.height)
            .clipped()
        }
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
            ],
            isWeatherBackgroundEnabled: true
        )
    }
}

// --- Preview ---
#Preview(as: .systemMedium) {
    WeatherWidgets()
} timeline: {
    SimpleEntry(date: .now, weatherData: .placeholder)
}
