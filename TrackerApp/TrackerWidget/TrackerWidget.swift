//
//  TrackerWidget.swift
//  TrackerWidget
//
//  Created by ezen on 08/08/2024.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Configuration
struct ConfigurationAppIntent: WidgetConfigurationIntent {
	
	static var title: LocalizedStringResource = "Configuration"
	
	static var description = IntentDescription("Set up your tracking informations")

	@Parameter(title: "Element ID", default: "ct")
	var elementId: String
	
	@Parameter(title: "Element Type", default: "div")
	var elementType: String
	
	struct ElementTypeOptionsProvider: DynamicOptionsProvider {
		func results() async throws -> [String] {
			["Div", "Span", "Paragraphe"]
		}
	}
}

// MARK: - Provider
struct TrackingEntry: TimelineEntry {
	
	let date: Date
	
	let configuration: ConfigurationAppIntent
}

struct Provider: AppIntentTimelineProvider {
	
	func placeholder(in context: Context) -> TrackingEntry {
		TrackingEntry(date: Date(), configuration: ConfigurationAppIntent())
	}
	
	func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> TrackingEntry {
		TrackingEntry(date: Date(), configuration: configuration)
	}
	
	func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<TrackingEntry> {
		var entries: [TrackingEntry] = []
		
		// Generate a timeline consisting of five entries an hour apart, starting from the current date.
		let currentDate = Date()
		for hourOffset in 0 ..< 5 {
			let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
			let entry = TrackingEntry(date: entryDate, configuration: configuration)
			entries.append(entry)
		}
		
		let nextUpdateTime: Date = .now.addingTimeInterval(10) // TODO: Extend time
		let entry = TrackingEntry(date: .now, configuration: configuration)
		return Timeline(entries: [entry], policy: .after(nextUpdateTime))
	}
}

struct TrackerWidgetEntryView : View {
	var entry: Provider.Entry
	
	@Environment(\.widgetFamily) var family
	
	var body: some View {
		Group {
			switch family {
			case .systemSmall:
				VStack(alignment: .leading, spacing: 5) {
					Text("Your Amazon article")
						.font(.footnote)
					Text("Price")
						.font(.title2)
						.fontWeight(.heavy)
					Spacer()
					
					HStack(alignment: .top, spacing: 0) {
						Text("12")
							.font(.largeTitle.bold())
						Text("99")
							.font(.headline.bold())
							.offset(CGSize(width: 0.0, height: 5.0))
						Text(" $ ")
							.font(.largeTitle)
					}
				}
				
			case .systemMedium:
				VStack(alignment: .leading, spacing: 5) {
					Text("Your Amazon article")
						.font(.footnote)
					Text("Price")
						.font(.title2)
						.fontWeight(.heavy)
					Spacer()
					
					HStack(alignment: .top, spacing: 0) {
						Text("12")
							.font(.largeTitle.bold())
						Text("99")
							.font(.headline.bold())
							.offset(CGSize(width: 0.0, height: 5.0))
						Text(" $ ")
							.font(.largeTitle)
					}
				}
			default:
				EmptyView()
			}
		}
		.padding(.vertical, 5)
		.foregroundColor(.white)
		.containerBackground(for: .widget) {
			Image("BackgroundWidget")
				.resizable()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.scaleEffect(CGSize(width: 1.2, height: 1.2))
				.scaledToFill()
				.blur(radius: 5.0)
		}
	}
}

struct TrackerWidget: Widget {
	let kind: String = "TrackerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            TrackerWidgetEntryView(entry: entry)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var clock: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.elementId = "ct"
        intent.elementType = "span"
        return intent
    }
    
    fileprivate static var timeZone: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
		intent.elementId = "cta"
		intent.elementType = "span"
        return intent
    }
}

#Preview(as: .systemMedium) {
    TrackerWidget()
} timeline: {
	TrackingEntry(date: .now, configuration: .clock)
//	TrackingEntry(date: .now, configuration: .timeZone)
}
