//
//  TrackerWidgetBundle.swift
//  TrackerWidget
//
//  Created by ezen on 08/08/2024.
//

import WidgetKit
import SwiftUI

@main
struct TrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TrackerWidget()
        TrackerWidgetLiveActivity()
    }
}
