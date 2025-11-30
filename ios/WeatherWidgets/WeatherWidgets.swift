import WidgetKit
import SwiftUI
import UIKit

// Data Model.
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

// Data Provider.
struct Provider: TimelineProvider {
    let appGroupIdentifier = "group.dmytrowidget"
    
    // Helper function to fetch weather data from UserDefaults.
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
        
        // Retrieve data from Shared Defaults.
        let emoji = sharedDefaults.string(forKey: keys["emoji"]!)
        let location = sharedDefaults.string(forKey: keys["location"]!)
        let temperature = sharedDefaults.string(forKey: keys["temperature"]!)
        let recommendation = sharedDefaults.string(forKey: keys["recommendation"]!)
        let lastUpdated = sharedDefaults.string(forKey: keys["lastUpdated"]!)
        let imagePath = sharedDefaults.string(forKey: keys["imagePath"]!)
        let forecastDataString = sharedDefaults.string(forKey: keys["forecastData"]!)
        
        var forecast: [ForecastItem]?
        if let forecastDataString = forecastDataString,
           let data = forecastDataString.data(using: .utf8) {
            do {
                let forecastResponse = try JSONDecoder().decode([String: [ForecastItem]].self, from: data)
                forecast = forecastResponse["forecast"]
            } catch {
                print("Error decoding forecast data: \(error)")
            }
        }

        // Create and return WeatherData struct.
        return WeatherData(
            emoji: emoji,
            location: location,
            temperature: temperature,
            recommendation: recommendation,
            lastUpdated: lastUpdated,
            imagePath: imagePath,
            forecast: forecast,
        )
    }
    
    func placeholder(
        in context: Context,
    ) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            weatherData: WeatherData(
                emoji: "☀️",
                location: "Placeholder",
                temperature: "25°C",
                recommendation: "Shorts and T-shirt",
                lastUpdated: "Just now",
                imagePath: nil,
                forecast: [],
            ),
        )
    }
    
    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> (),
    ) {
        let entry = SimpleEntry(
            date: Date(),
            weatherData: getWeatherData() ?? WeatherData(
                emoji: "☀️",
                location: "Snapshot",
                temperature: "25°C",
                recommendation: "Shorts and T-shirt",
                lastUpdated: "Just now",
                imagePath: nil,
                forecast: [],
            ),
        )
        completion(entry)
    }
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> (),
    ) {
        
        let currentDate = Date()
        let entry = SimpleEntry(
            date: currentDate,
            weatherData: getWeatherData() ?? WeatherData(
                emoji: "☀️",
                location: "Timeline",
                temperature: "25°C",
                recommendation: "Shorts and T-shirt",
                lastUpdated: "Just now",
                imagePath: nil,
                forecast: [],
            ),
        )
        
        // Update every 15 minutes.
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// Widget Entry View.
struct WeatherWidgetsEntryView: View {
    var entry: Provider.Entry
    
    func loadImage(from filePath: String?) -> some View {
        guard let filePath = filePath else {
            return AnyView(Image(systemName: "photo").resizable().scaledToFit())
        }
        
        let fileURL = URL(fileURLWithPath: filePath)
        if let imageData = try? Data(contentsOf: fileURL),
           let uiImage = UIImage(data: imageData) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        } else {
            return AnyView(Image(systemName: "photo").resizable().scaledToFit())
        }
    }
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
            
            if let imagePath = entry.weatherData.imagePath, !isImageMissing(imagePath: imagePath),
               let uiImage = UIImage(contentsOfFile: imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .cornerRadius(12)
                    .overlay(
                        VStack {
                            // Top-left app name with wrapping and background
                            HStack {
                                Text("WeatherFit")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .padding(6)
                                    .background(.background.opacity(0.5))
                                    .cornerRadius(8)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .padding([.top, .leading], 4)
                                Spacer()
                            }
                            
                            Spacer()
                            
                            // Bottom-right temperature and last updated
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(entry.weatherData.temperature ?? "")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    Text(entry.weatherData.lastUpdated ?? "")
                                        .font(.caption2)
                                        .foregroundColor(.primary)
                                }
                                .padding(6)
                                .background(.background.opacity(0.7))
                                .cornerRadius(8)
                                // Limit width to wrap nicely.
                                .frame(maxWidth: 100, alignment: .trailing)
                                .multilineTextAlignment(.trailing)
                                .padding([.bottom, .trailing], 4)
                            }
                        }
                    )
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding()
            }

        }
        .widgetURL(URL(string: "weatherfit://open")!)
    }
    
    func isImageMissing(imagePath: String?) -> Bool {
        guard let path = imagePath else { return true }
        let fileURL = URL(fileURLWithPath: path)
        return (try? Data(contentsOf: fileURL)) == nil
    }
    
    func getDay(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateString) else { return "" }
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        return dayFormatter.string(from: date)
    }

    func getTime(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateString) else { return "" }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "ha"
        return timeFormatter.string(from: date)
    }
    
    func getWeatherEmoji(for code: Int) -> String {
        switch code {
            case 0: return "☀️"
            case 1, 2, 3: return "☁️"
            case 45, 48: return "🌫"
            case 51, 53, 55, 56, 57: return "🌧"
            case 61, 63, 65, 66, 67: return "🌧"
            case 71, 73, 75, 77: return "❄️"
            case 80, 81, 82: return "⛈"
            case 85, 86: return "🌨"
            case 95, 96, 99: return "🌪"
            default: return "🤔"
        }
    }
}

// Widget Definition.
struct WeatherWidgets: Widget {
    // In the Widget Configuration it is important to set the kind to the same
    // value as the name/iOSName in the updateWidget function in Flutter.
    let kind: String = "WeatherWidgets"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider(),
        ) { entry in
            if #available(iOS 17.0, *) {
                WeatherWidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WeatherWidgetsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("WeatherFit")
        .description("Check the weather and outfit recommendation.")
    }
}

// Preview.
#Preview(as: .systemMedium) {
    WeatherWidgets()
} timeline: {
    SimpleEntry(
        date: .now,
        weatherData: WeatherData(
            emoji: "☀️",
            location: "Preview",
            temperature: "25°C",
            recommendation: "Shorts and T-shirt",
            lastUpdated: "Just now",
            imagePath: nil,
            forecast: [
                ForecastItem(time: "2023-10-27T12:00:00.000Z", temperature: 25.0, weatherCode: 0),
                ForecastItem(time: "2023-10-28T12:00:00.000Z", temperature: 22.0, weatherCode: 1),
                ForecastItem(time: "2023-10-29T12:00:00.000Z", temperature: 20.0, weatherCode: 80),
                ForecastItem(time: "2023-10-30T12:00:00.000Z", temperature: 18.0, weatherCode: 61),
            ]
        ),
    )
}
