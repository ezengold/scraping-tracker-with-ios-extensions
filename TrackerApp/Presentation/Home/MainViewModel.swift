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
	
	@Published var querySelector: String = ""
	
	@Published var item: TrackedItem = TrackedItem() {
		didSet {
			saveValues()
		}
	}
	
	@Published var isLoading: Bool = false
	
	@Published var timer: Timer?
	
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
			
			if let safeSelector = Store.string(forKey: Constants.CONTENT_SELECTOR_KEY), !safeSelector.isEmpty {
				self.querySelector = safeSelector
			} else {
				Store.setValue("#ct", forKey: Constants.CONTENT_SELECTOR_KEY)
				self.querySelector = "#ct"
			}
		}
	}
	
	func fetchData() {
		self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
			self.isLoading = true
			
			Task {
				let _item = await self.fetchItemUseCase.execute(at: self.url, withSelector: self.querySelector)
				
				withAnimation {
					self.item = _item
				}
				
				self.isLoading = false
			}
		}
	}
	
	func startFetching() {
		self.timer?.fire()
	}
	
	func stopFetching() {
		self.timer?.invalidate()
		self.timer = nil
		self.isLoading = false
	}
	
	func saveValues() {
		if let Store = UserDefaults(suiteName: Constants.ROOT_KEY) {
			Store.setValue(self.url, forKey: Constants.CONTENT_URL_KEY)
			Store.setValue(self.querySelector, forKey: Constants.CONTENT_SELECTOR_KEY)
		}
	}
}
