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

	@Parameter(title: "Selector", default: "#ct")
	var querySelector: String {
		didSet {
			UserDefaults(suiteName: Constants.ROOT_KEY)?.setValue(querySelector, forKey: Constants.CONTENT_SELECTOR_KEY)
		}
	}
	
	var url: String = UserDefaults(suiteName: Constants.ROOT_KEY)?.string(forKey: Constants.CONTENT_URL_KEY) ?? ""
	
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
	
	let item: TrackedItem
	
	let configuration: ConfigurationAppIntent
}

struct Provider: AppIntentTimelineProvider {
	
	func placeholder(in context: Context) -> TrackingEntry {
		TrackingEntry(date: Date(), item: TrackedItem(), configuration: ConfigurationAppIntent())
	}
	
	func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> TrackingEntry {
		TrackingEntry(date: Date(), item: TrackedItem(), configuration: configuration)
	}
	
	func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<TrackingEntry> {
		if !configuration.url.isEmpty {
			let _item = await FetchItemUseCase(api: ContentApiImpl.shared).execute(at: configuration.url, withSelector: configuration.querySelector)
			
			let entry = TrackingEntry(date: Date(), item: _item, configuration: configuration)
			
			return Timeline(entries: [entry], policy: .atEnd)
		} else {
			return Timeline(entries: [.init(date: Date(), item: TrackedItem(), configuration: .init())], policy: .after(.now.addingTimeInterval(30))) // retry after 30 secs
		}
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
						Text(entry.item.price)
							.font(.largeTitle.bold())
							.contentTransition(.numericText())
						Text(entry.item.cents)
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
							Text("\(entry.item.discount)%")
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
								Text(entry.item.price)
									.font(.largeTitle.bold())
									.contentTransition(.numericText())
								Text(entry.item.cents)
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
						Text("$ \(entry.item.price)")
							.font(.largeTitle.bold())
							.contentTransition(.numericText())
						Text(entry.item.cents)
							.font(.headline.bold())
							.contentTransition(.numericText())
							.offset(CGSize(width: 0.0, height: -10.0))
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				
			case .accessoryInline:
				VStack(alignment: .leading, spacing: 5) {
					Text("Tracked Price is $\(entry.item.price),\(entry.item.cents)")
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
	
    fileprivate static var price0: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.querySelector = "#ct"
        return intent
    }
    
    fileprivate static var price1: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
		intent.querySelector = "#ct"
		return intent
	}
	
	fileprivate static var price2: ConfigurationAppIntent {
		let intent = ConfigurationAppIntent()
		intent.querySelector = "#ct"
		return intent
	}
}

#Preview(as: .systemMedium) {
    TrackerWidget()
} timeline: {
	TrackingEntry(date: .now, item: TrackedItem(price: "10", cents: "49", discount: "-13"), configuration: ConfigurationAppIntent())
	TrackingEntry(date: .now, item: TrackedItem(price: "13", cents: "99", discount: "-3"), configuration: ConfigurationAppIntent())
	TrackingEntry(date: .now, item: TrackedItem(price: "16", cents: "65", discount: "-5"), configuration: ConfigurationAppIntent())
}
