import WidgetKit
import SwiftUI
import UIKit

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
        if let forecastDataString = forecastDataString, let data = forecastDataString.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let forecastResponse = try decoder.decode([String: [ForecastItem]].self, from: data)
                forecast = forecastResponse["forecast"]
            } catch {
                print("WIDGET FORECAST DECODING FAILED: \(error)")
            }
        }
        
        return WeatherData(emoji: emoji, location: location, temperature: temperature, recommendation: recommendation, lastUpdated: lastUpdated, imagePath: imagePath, forecast: forecast)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), weatherData: .placeholder)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), weatherData: getWeatherData() ?? .placeholder)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
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
    
    var body: some View {
        VStack(spacing: 4) {
            Text(DateHelper.getDay(from: item.time))
                .font(.caption2).bold()
            Text(DateHelper.getTimeOfDay(from: item.time))
                .font(.caption)
            Text(WeatherHelper.getWeatherEmoji(for: item.weatherCode))
                .font(.title3)
            Text("\(Int(item.temperature.rounded()))°")
                .font(.caption)
        }
    }
}

// This view now ONLY contains the foreground content.
struct WeatherWidgetsEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section: Location and Emoji
            HStack {
                Text(entry.weatherData.location ?? "Unknown Location")
                    .font(.headline).fontWeight(.semibold)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(entry.weatherData.temperature ?? "--")
                        .font(.title3).fontWeight(.bold)
                    Text(entry.weatherData.lastUpdated ?? "never")
                        .font(.caption2)
                }
                .frame(width: 80, alignment: .trailing)
                .multilineTextAlignment(.trailing)
                Spacer()
                Text(entry.weatherData.emoji ?? "")
                    .font(.largeTitle)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Middle section: Recommendation
            Text(entry.weatherData.recommendation ?? "No recommendation available.")
                .font(.subheadline).fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // Bottom section: Forecast
            HStack(alignment: .bottom) {
                if let forecast = entry.weatherData.forecast, !forecast.isEmpty {
                    HStack(alignment: .bottom) {
                        ForEach(Array(forecast.enumerated()), id: \.element.time) { index, item in
                            ForecastItemView(item: item)
                            if index < forecast.count - 1 {
                                Spacer()
                            }
                        }
                    }
                } else {
                    Text("No forecast data.").font(.caption)
                }
            }
            .padding(12)
        }
        .padding(8)
        .widgetURL(URL(string: "weatherfit://open")!)
    }
}

// --- Widget Definition ---
struct WeatherWidgets: Widget {
    let kind: String = "WeatherWidgets"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            // The content view is passed here.
            WeatherWidgetsEntryView(entry: entry)
            // The .containerBackground modifier handles the background for iOS 17+
                .containerBackground(for: .widget) {
                    // This ZStack provides either an image or a gradient fallback.
                    ZStack {
                        // We always show the gradient as a base background
                        WeatherHelper.getGradient(for: entry.weatherData.forecast?.first?.weatherCode ?? 0)
                        
                        // NOTE: There is a persistent 'CFPrefsPlistSource' error that can prevent
                        // the app from correctly reading the imagePath from the shared container.
                        if let imagePath = entry.weatherData.imagePath, let uiImage = UIImage(contentsOfFile: imagePath) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
        }
        .configurationDisplayName("WeatherFit")
        .description("Check the weather and outfit recommendation.")
    }
}

// --- Helpers & Extensions ---

struct DateHelper {
    private static func parseDateTime(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return formatter.date(from: string)
    }
    
    static func getDay(from dateString: String) -> String {
        guard let date = parseDateTime(from: dateString) else { return "" }
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInTomorrow(date) { return "Tomorrow" }
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        return dayFormatter.string(from: date)
    }
    
    static func getTimeOfDay(from dateString: String) -> String {
        guard let date = parseDateTime(from: dateString) else { return "" }
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5...11: return "Morning"
        case 12...16: return "Lunch"
        case 17...21: return "Evening"
        default: return "Night"
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
        case 0: // Sunny
            gradient = Gradient(colors: [Color(red: 1.0, green: 0.75, blue: 0.0), Color(red: 0.9, green: 0.45, blue: 0.0)])
        case 1, 2, 3, 45, 48: // Cloudy/Foggy
            gradient = Gradient(colors: [Color(red: 0.6, green: 0.7, blue: 0.8), Color(red: 0.4, green: 0.5, blue: 0.6)])
        case 51...67, 80...82: // Rain/Showers
            gradient = Gradient(colors: [Color(red: 0.3, green: 0.4, blue: 0.5), Color(red: 0.1, green: 0.2, blue: 0.3)])
        case 71...77, 85, 86: // Snow
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
