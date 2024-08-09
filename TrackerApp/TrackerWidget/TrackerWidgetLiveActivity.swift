//
//  TrackerWidgetLiveActivity.swift
//  TrackerWidget
//
//  Created by ezen on 08/08/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TrackerWidgetAttributes: ActivityAttributes {
	
	public struct ContentState: Codable, Hashable {
		
		var elementId: String
		
		var elementType: String
	}
	
	var name: String
}

struct TrackerWidgetLiveActivity: Widget {
	var body: some WidgetConfiguration {
		ActivityConfiguration(for: TrackerWidgetAttributes.self) { context in
			// Lock screen/banner UI goes here
			VStack {
				Text("Hello \(context.attributes.name)")
			}
			.activityBackgroundTint(Color.cyan)
			.activitySystemActionForegroundColor(Color.black)
		} dynamicIsland: { context in
			DynamicIsland {
				// Expanded UI goes here.  Compose the expanded UI through
				// various regions, like leading/trailing/center/bottom
				DynamicIslandExpandedRegion(.leading) {
					Text("Leading")
				}
				DynamicIslandExpandedRegion(.trailing) {
					Text("Trailing")
				}
				DynamicIslandExpandedRegion(.bottom) {
					Text("Hello \(context.attributes.name)")
					// more content
				}
			} compactLeading: {
				Text("L")
			} compactTrailing: {
				Text("T \(context.state.elementId)")
			} minimal: {
				Text(context.state.elementId)
			}
			.keylineTint(Color.red)
		}
	}
}

extension TrackerWidgetAttributes {
	fileprivate static var preview: TrackerWidgetAttributes {
		TrackerWidgetAttributes(name: "World")
	}
}

extension TrackerWidgetAttributes.ContentState {
	fileprivate static var clock: TrackerWidgetAttributes.ContentState {
		TrackerWidgetAttributes.ContentState(elementId: "ct", elementType: "span")
	}
	
	fileprivate static var timeZone: TrackerWidgetAttributes.ContentState {
		TrackerWidgetAttributes.ContentState(elementId: "cta", elementType: "span")
	}
}

#Preview("Notification", as: .content, using: TrackerWidgetAttributes.preview) {
	TrackerWidgetLiveActivity()
} contentStates: {
	TrackerWidgetAttributes.ContentState.clock
	TrackerWidgetAttributes.ContentState.timeZone
}
