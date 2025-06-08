import WidgetKit
import SwiftUI
import UIKit

// Data Model.
struct WeatherData: Codable {
    let emoji: String?
    let location: String?
    let temperature: String?
    let recommendation: String?
    let lastUpdated: String?
    let imagePath: String?
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
        
        // Use the correct keys, matching Android's SharedPreferences keys.
        let keys: [String: String] = [
            "emoji": "text_emoji",
            "location": "text_location",
            "temperature": "text_temperature",
            "recommendation": "text_recommendation",
            "lastUpdated": "text_last_updated",
            "imagePath": "image_weather",
        ]
        
        // Retrieve data from Shared Defaults.
        let emoji = sharedDefaults.string(forKey: keys["emoji"]!)
        let location = sharedDefaults.string(forKey: keys["location"]!)
        let temperature = sharedDefaults.string(forKey: keys["temperature"]!)
        let recommendation = sharedDefaults.string(forKey: keys["recommendation"]!)
        let lastUpdated = sharedDefaults.string(forKey: keys["lastUpdated"]!)
        let imagePath = sharedDefaults.string(forKey: keys["imagePath"]!)
        
        // Create and return WeatherData struct.
        return WeatherData(
            emoji: emoji,
            location: location,
            temperature: temperature,
            recommendation: recommendation,
            lastUpdated: lastUpdated,
            imagePath: imagePath,
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
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(8)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .padding([.top, .leading], 8)
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
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(8)
                                // Limit width to wrap nicely.
                                .frame(maxWidth: 100, alignment: .trailing)
                                .multilineTextAlignment(.trailing)
                                .padding([.bottom, .trailing], 8)
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
        ),
    )
}
