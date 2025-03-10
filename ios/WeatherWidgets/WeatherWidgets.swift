//
//  WeatherWidgets.swift
//  WeatherWidgets
//
//  Created by Dmytro on 2024-03-02.
//

import WidgetKit
import SwiftUI
import CoreLocation

// 1. Data Model
struct WeatherData: Codable {
    let emoji: String?
    let location: String?
    let temperature: String?
    let recommendation: String?
    let lastUpdated: String?
    let imageURL: String?
}

// 2. Data Provider
struct Provider: TimelineProvider {
    
    let appGroupIdentifier = "group.com.turskyi.weatherfit"
    
    // Helper function to fetch weather data from UserDefaults
    func getWeatherData() -> WeatherData? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("Could not load shared defaults.")
            return nil
        }
        
        guard let weatherData = sharedDefaults.object(forKey: "weatherData") as? Data else {
            print("No weather data in shared defaults.")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let weather = try decoder.decode(WeatherData.self, from: weatherData)
            return weather
        } catch {
            print("Error decoding weather data: \(error)")
            return nil
        }
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), weatherData: WeatherData(emoji: "☀️", location: "Placeholder", temperature: "25°C", recommendation: "Shorts and T-shirt", lastUpdated: "Just now", imageURL: nil))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), weatherData: getWeatherData() ?? WeatherData(emoji: "☀️", location: "Snapshot", temperature: "25°C", recommendation: "Shorts and T-shirt", lastUpdated: "Just now", imageURL: nil))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), weatherData: getWeatherData() ?? WeatherData(emoji: "☀️", location: "Timeline", temperature: "25°C", recommendation: "Shorts and T-shirt", lastUpdated: "Just now", imageURL: nil))
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let weatherData: WeatherData
}

// 3. Widget Entry View
struct WeatherWidgetsEntryView : View {
    var entry: Provider.Entry
    
    // Function to load image from URL
    func loadImage(from urlString: String?) -> some View {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return AnyView(Image(systemName: "photo").resizable().scaledToFit())
        }
        
        return AnyView(AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        })
    }

    var body: some View {
        ZStack {
            // Optional: Background color.
            Color.gray.opacity(0.3)
            VStack(alignment: .leading) {
                
                HStack {
                    Text(entry.weatherData.emoji ?? "")
                        .font(.largeTitle)
                    
                    Spacer()
                    
                    Text(entry.weatherData.location ?? "")
                }

                Text(entry.weatherData.temperature ?? "")
                    .font(.title)
                
                if let imageURL = entry.weatherData.imageURL {
                    loadImage(from: imageURL)
                }
                
                Text(entry.weatherData.recommendation ?? "")
                    .font(.footnote)

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
}

// 4. Widget Definition
struct WeatherWidgets: Widget {
    let kind: String = "WeatherWidgets"

    var body: some WidgetConfiguration {
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
}

// 5. Preview
#Preview(as: .systemMedium) {
    WeatherWidgets()
} timeline: {
    SimpleEntry(date: .now, weatherData: WeatherData(emoji: "☀️", location: "Preview", temperature: "25°C", recommendation: "Shorts and T-shirt", lastUpdated: "Just now", imageURL: nil))
}
