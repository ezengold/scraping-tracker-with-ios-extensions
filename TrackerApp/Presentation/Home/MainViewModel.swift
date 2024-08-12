//
//  MainViewModel.swift
//  TrackerApp
//
//  Created by ezen on 08/08/2024.
//

import Foundation
import UIKit

class MainViewModel: ObservableObject {
	var host: MainViewController
	
	var fetchContentUseCase = FetchContentUseCase(api: ContentApiImpl.shared)
	
	@Published var url: String = "https://www.timeanddate.com/worldclock/timezone/utc"
	//	@Published var url: String = UserDefaults.standard.string(forKey: Constants.CONTENT_URL_KEY) ?? "https://www.timeanddate.com/worldclock/timezone/utc"
	
	@Published var querySelector: String = "#ct"
	//	@Published var querySelector: String = UserDefaults.standard.string(forKey: Constants.CONTENT_SELECTOR_KEY) ?? "#ct"
	
	@Published var tagName: String = "span"
	//	@Published var tagName: String = UserDefaults.standard.string(forKey: Constants.CONTENT_TAG_KEY) ?? "span"
	
	@Published var value: String = UserDefaults.standard.string(forKey: Constants.CONTENT_VALUE_KEY) ?? ""
	
	@Published var isLoading: Bool = false
	
	@Published var timer: Timer?
	
	init(host: UIViewController) {
		if let safeHost = host as? MainViewController {
			self.host = safeHost
		} else {
			self.host = MainViewController()
		}
	}
	
	func fetchData() {
		self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
			self.isLoading = true
			
			Task {
				do {
					let _document = try await self.fetchContentUseCase.execute(at: self.url)
					
					self.value = self.parseAndGetElement(from: _document)
					
					self.isLoading = false
				} catch {
					print("Error: \(error.localizedDescription)")
					self.isLoading = false
				}
			}
		}
	}
	
	func parseAndGetElement(from str: String) -> String {
		print(str)
		return "NO-CONTENT-FOUND"
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
		UserDefaults.standard.setValue(self.url, forKey: Constants.CONTENT_URL_KEY)
		UserDefaults.standard.setValue(self.querySelector, forKey: Constants.CONTENT_SELECTOR_KEY)
		UserDefaults.standard.setValue(self.tagName, forKey: Constants.CONTENT_TAG_KEY)
		UserDefaults.standard.setValue(self.value, forKey: Constants.CONTENT_VALUE_KEY)
	}
}
