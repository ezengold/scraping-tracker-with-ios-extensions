//
//  MainViewModel.swift
//  TrackerApp
//
//  Created by ezen on 08/08/2024.
//

import Foundation
import UIKit
import SwiftSoup
import SwiftUI

class MainViewModel: ObservableObject {
	var host: MainViewController
	
	var fetchItemUseCase = FetchItemUseCase(api: ContentApiImpl.shared)
	
	@Published var url: String = ""
	
	@Published var item: TrackedItem = TrackedItem() {
		didSet {
			saveValues()
		}
	}
	
	@Published var isLoading: Bool = false
	
	init(host: UIViewController) {
		if let safeHost = host as? MainViewController {
			self.host = safeHost
		} else {
			self.host = MainViewController()
		}
		if let Store = UserDefaults(suiteName: Constants.ROOT_KEY) {
			if let safeUrl = Store.string(forKey: Constants.CONTENT_URL_KEY), !safeUrl.isEmpty {
				self.url = safeUrl
			} else {
				Store.setValue("https://www.timeanddate.com/worldclock/timezone/utc", forKey: Constants.CONTENT_URL_KEY)
				self.url = "https://www.timeanddate.com/worldclock/timezone/utc"
			}
		}
	}
	
	func fetchData() {
		self.isLoading = true
		
		Task {
			let _item = await self.fetchItemUseCase.execute(at: self.url)
			
			withAnimation {
				self.item = _item
			}
			
			self.isLoading = false
		}
	}
	
	func saveValues() {
		if let Store = UserDefaults(suiteName: Constants.ROOT_KEY) {
			Store.setValue(self.url, forKey: Constants.CONTENT_URL_KEY)
		}
	}
}
