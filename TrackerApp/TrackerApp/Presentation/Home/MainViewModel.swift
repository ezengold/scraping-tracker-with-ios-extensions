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
	
	@Published var data = [String]()
	
	@Published var isConnected: Bool = false
	
	init(host: UIViewController) {
		if let safeHost = host as? MainViewController {
			self.host = safeHost
		} else {
			self.host = MainViewController()
		}
	}
	
	func onConnect() {
		BackendApi.shared.connect(with: self)
	}
}

extension MainViewModel: BackendApiListener {
	
	func onConnected() {
		self.isConnected = true
	}
	
	func onDisconnected() {
		self.isConnected = false
	}
	
	func onError(error: String) {
		print("Error: \(error)")
	}
	
	func onReceived(dataReceived data: String) {
		print("Data: \(data)")
		self.data.append(data)
	}
}
