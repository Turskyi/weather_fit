//
//  WeatherWidgets.swift
//  WeatherWidgets
//
//  Created by Dmytro on 2025-06-08.
//

import WidgetKit
import SwiftUI
import Cocoa
import AppKit

// Typealias UIImage to NSImage.
typealias UIImage = NSImage

// For macOS, NSImage is in AppKit.
extension NSImage {
    static func fromString(named name: String) -> NSImage? {
        // This directly calls the system init.
        return NSImage(named: NSImage.Name(name))
    }
}

// 1. Data Model
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

// 2. Data Provider
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
        
        //Retrieve data from Shared Defaults.
        let emoji = sharedDefaults.string(forKey: keys["emoji"]!)
        let location = sharedDefaults.string(forKey: keys["location"]!)
        let temperature = sharedDefaults.string(forKey: keys["temperature"]!)
        let recommendation = sharedDefaults.string(forKey: keys["recommendation"]!)
        let lastUpdated = sharedDefaults.string(forKey: keys["lastUpdated"]!)
        let imagePath = sharedDefaults.string(forKey: keys["imagePath"]!)
        
        // Create and return WeatherData struct.
        return WeatherData(emoji: emoji, location: location, temperature: temperature, recommendation: recommendation, lastUpdated: lastUpdated, imagePath: imagePath)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), weatherData: WeatherData(emoji: "☀️", location: "Placeholder", temperature: "25°C", recommendation: "Shorts and T-shirt", lastUpdated: "Just now", imagePath: nil))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), weatherData: getWeatherData() ?? WeatherData(emoji: "☀️", location: "Snapshot", temperature: "25°C", recommendation: "Shorts and T-shirt", lastUpdated: "Just now", imagePath: nil))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, weatherData: getWeatherData() ?? WeatherData(emoji: "☀️", location: "Timeline", temperature: "25°C", recommendation: "Shorts and T-shirt", lastUpdated: "Just now", imagePath: nil))
        //update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// 3. Widget Entry View
struct WeatherWidgetsEntryView: View {
    var entry: Provider.Entry
    
    // Function to load image from file path
    func loadImage(from filePath: String?) -> some View {
        guard let filePath = filePath else {
            return AnyView(Image(systemName: "photo").resizable().scaledToFit())
        }
        
        let fileURL = URL(fileURLWithPath: filePath)
        if let imageData = try? Data(contentsOf: fileURL), let uiImage = UIImage(data: imageData) {
            return AnyView(Image(nsImage: uiImage).resizable().scaledToFit())
        } else {
            return AnyView(Image(systemName: "photo").resizable().scaledToFit())
        }
    }
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
            VStack(alignment: .leading) {
                HStack {
                    Text(entry.weatherData.emoji ?? "")
                        .font(isImageMissing(imagePath: entry.weatherData.imagePath) ? .system(size: 60) : .largeTitle)
                    Spacer()
                    Text(entry.weatherData.location ?? "")
                }
                
                Text(entry.weatherData.temperature ?? "")
                    .font(.title)
                
                if let imagePath = entry.weatherData.imagePath, !isImageMissing(imagePath: imagePath) {
                    loadImage(from: imagePath)
                        .frame(height: 100)
                } else if entry.weatherData.recommendation == nil || entry.weatherData.recommendation?.isEmpty == true {
                    // Default messages with emojis.
                    let defaultMessages: [String] = [
                        "👕 Oops! No outfit suggestion available.",
                        "🤷 Looks like we couldn’t pick an outfit this time.",
                        "🎭 No recommendation? Time to mix & match your own style!",
                        "💡 Your fashion instincts take the lead today!",
                        "🚀 AI is taking a fashion break. Try again!",
                        "🛌 No outfit picked—maybe today is a pajama day?",
                        "❌ No outfit available",
                        "🤔 no recommendation"
                    ]
                    
                    Text(defaultMessages.randomElement() ?? "")
                        .font(isImageMissing(imagePath: entry.weatherData.imagePath) ? .title : .footnote)
                }
                
                Text(entry.weatherData.recommendation ?? "")
                    .font(isImageMissing(imagePath: entry.weatherData.imagePath) ? .title : .footnote)
                
                Spacer()
                
                HStack {
                    Text("Last updated:")
                    Text(entry.weatherData.lastUpdated ?? "")
                        .font(.footnote)
                }
            }
            .padding()
        }
        .widgetURL(URL(string: "weatherfit://open")!)
    }
    
    func isImageMissing(imagePath: String?) -> Bool {
        guard let path = imagePath else {
            return true // Handles the imagePath == nil case
        }
        let fileURL = URL(fileURLWithPath: path)
        return (try? Data(contentsOf: fileURL)) == nil
    }
}

// 4. Widget Definition
@main
public struct WeatherWidgets: Widget {
    // In the Widget Configuration it is important to set the kind to the same
    // value as the name/iOSName in the updateWidget function in Flutter.
    let kind: String = "WeatherWidgets"
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WeatherWidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WeatherWidgetsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Weather Fit")
        .description("Check the weather and outfit recommendation.")
    }
    
    public init() {}
}

// 5. Preview
#Preview(as: .systemMedium) {
    WeatherWidgets()
} timeline: {
    SimpleEntry(date: .now, weatherData: WeatherData(emoji: "☀️", location: "Preview", temperature: "25°C", recommendation: "Shorts and T-shirt", lastUpdated: "Just now", imagePath: nil))
}
