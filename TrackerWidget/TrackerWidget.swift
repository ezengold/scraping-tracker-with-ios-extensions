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
	
	static var title: LocalizedStringResource = "Tracking Configuration"
	
	static var description = IntentDescription("Set up your tracking informations")

	@Parameter(title: "URL of the Product", default: "")
	var url: String {
		didSet {
			UserDefaults(suiteName: Constants.ROOT_KEY)?.setValue(url, forKey: Constants.CONTENT_URL_KEY)
		}
	}
	
	init() {
		self.url = UserDefaults(suiteName: Constants.ROOT_KEY)?.string(forKey: Constants.CONTENT_URL_KEY) ?? ""
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
			let _item = await FetchItemUseCase(api: ContentApiImpl.shared).execute(at: configuration.url)
			
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
					Text("Order now with")
						.font(.system(size: 15))
						.frame(maxWidth: .infinity, alignment: .leading)
					Text("-\(entry.item.discount)%")
						.font(.system(size: 25).monospacedDigit())
						.fontWeight(.heavy)
						.foregroundColor(.green)
						.frame(maxWidth: .infinity, alignment: .leading)
					Text("Discount")
						.font(.system(size: 15))
						.frame(maxWidth: .infinity, alignment: .leading)
					Spacer()
					
					Text("\(entry.item.price)")
						.font(.system(size: 20).bold())
						.contentTransition(.numericText())
						.frame(maxWidth: .infinity, alignment: .leading)
				}
				
			case .systemMedium:
				ZStack {
					VStack(alignment: .leading, spacing: 5) {
						Text("Your watched aricle")
							.font(.callout)
							.frame(maxWidth: .infinity, alignment: .leading)
						Text("Current Price")
							.font(.title2)
							.fontWeight(.heavy)
							.frame(maxWidth: .infinity, alignment: .leading)
						Spacer()
						
						HStack(alignment: .center, spacing: 0) {
							Text("-\(entry.item.discount)%")
								.font(.title.monospacedDigit())
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
								Text("\(entry.item.price)")
									.font(.title.bold().monospacedDigit())
									.contentTransition(.numericText())
							}
						}
					}
				}
				
			case .accessoryRectangular:
				VStack(alignment: .leading, spacing: 5) {
					Text("Get \(entry.item.discount)% discount")
						.fontWeight(.bold)
					Text("\(entry.item.price)")
						.font(.system(size: 22).weight(.heavy).monospacedDigit())
						.contentTransition(.numericText())
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				
			case .accessoryInline:
				VStack(alignment: .leading, spacing: 5) {
					Text("Get \(entry.item.discount)% discount now")
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

#Preview(as: .accessoryRectangular) {
    TrackerWidget()
} timeline: {
	TrackingEntry(date: .now, item: TrackedItem(price: "40735 FCFA", discount: "10"), configuration: ConfigurationAppIntent())
	TrackingEntry(date: .now, item: TrackedItem(price: "42997 FCFA", discount: "5"), configuration: ConfigurationAppIntent())
}
