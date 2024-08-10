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
	
	@Parameter(title: "Element Type", optionsProvider: ElementTypeOptionsProvider())
	var elementType: String
	
	var price: String = ""
	
	var cents: String = ""
	
	var discount: String = ""
	
	struct ElementTypeOptionsProvider: DynamicOptionsProvider {
		
		func results() async throws -> [String] {
			["span", "div", "p"]
		}
		
		func defaultResult() async -> String? {
			"span"
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
		let nextUpdateTime: Date = .now.addingTimeInterval(3) // TODO: Extend time
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
					
					Rectangle()
						.fill(Color.white.opacity(0.1))
						.frame(height: 1)
						.frame(maxWidth: .infinity)
						.padding(.bottom, 5)
					HStack(alignment: .top, spacing: 0) {
						Text(entry.configuration.price)
							.font(.largeTitle.bold())
							.contentTransition(.numericText())
						Text(entry.configuration.cents)
							.font(.headline.bold())
							.contentTransition(.numericText())
							.offset(CGSize(width: 0.0, height: 5.0))
						Text(" $ ")
							.font(.largeTitle)
					}
				}
				
			case .systemMedium:
				ZStack {
					VStack(alignment: .leading, spacing: 5) {
						Text("You Next Five Moves")
							.font(.callout)
							.frame(maxWidth: .infinity, alignment: .leading)
						Text("Current Price")
							.font(.title2)
							.fontWeight(.heavy)
							.frame(maxWidth: .infinity, alignment: .leading)
						Spacer()
						
						HStack(alignment: .center, spacing: 0) {
							Text("\(entry.configuration.discount)%")
								.font(.title)
								.contentTransition(.numericText())
								.foregroundColor(.green)
								.padding(.trailing, 5)
							VStack(spacing: 5) {
								Image(systemName: "arrowtriangle.up.fill")
									.resizable()
									.foregroundColor(.green)
									.frame(width: 10, height: 5)
								Image(systemName: "arrowtriangle.down.fill")
									.resizable()
									.foregroundColor(.white.opacity(0.5))
									.frame(width: 10, height: 5)
							}
							Spacer()
							HStack(alignment: .top, spacing: 0) {
								Text(entry.configuration.price)
									.font(.largeTitle.bold())
									.contentTransition(.numericText())
								Text(entry.configuration.cents)
									.font(.headline.bold())
									.contentTransition(.numericText())
									.offset(CGSize(width: 0.0, height: 5.0))
								Text(" $ ")
									.font(.largeTitle)
							}
						}
					}
				}
				
			case .accessoryRectangular:
				VStack(alignment: .leading, spacing: 5) {
					Text("Tracked Price is")
						.fontWeight(.bold)
					HStack(alignment: .center, spacing: 0) {
						Text("$ \(entry.configuration.price)")
							.font(.largeTitle.bold())
							.contentTransition(.numericText())
						Text(entry.configuration.cents)
							.font(.headline.bold())
							.contentTransition(.numericText())
							.offset(CGSize(width: 0.0, height: -10.0))
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				
			case .accessoryInline:
				VStack(alignment: .leading, spacing: 5) {
					Text("Tracked Price is $\(entry.configuration.price),\(entry.configuration.cents)")
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				
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
		.supportedFamilies([.systemSmall, .systemMedium, .accessoryInline, .accessoryRectangular])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var log1: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent(price: "12", cents: "99", discount: "-13")
        intent.elementId = "ct"
        intent.elementType = "span"
        return intent
    }
    
    fileprivate static var log2: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent(price: "13", cents: "79", discount: "0")
		intent.elementId = "cta"
		intent.elementType = "span"
        return intent
    }
}

#Preview(as: .accessoryRectangular) {
    TrackerWidget()
} timeline: {
	TrackingEntry(date: .now, configuration: .log1)
	TrackingEntry(date: .now, configuration: .log2)
}
