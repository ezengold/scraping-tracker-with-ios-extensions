//
//  BackendApi.swift
//  TrackerApp
//
//  Created by ezen on 08/08/2024.
//

import Foundation

@objc
protocol BackendApiListener {
	@objc optional func onReceived(dataReceived data: String)
	@objc optional func onError(error: String)
	@objc optional func onConnected()
	@objc optional func onDisconnected()
}

final class BackendApi: NSObject, URLSessionWebSocketDelegate {
	static let shared = BackendApi()
	
	var API_URL: String = "ws://127.0.0.1:5173"
	
	private var task: URLSessionWebSocketTask!
	
	private var delegate: BackendApiListener!
	
	func connect(with delegate: BackendApiListener) {
		self.delegate = delegate
		
		if let url = URL(string: API_URL) {
			self.task = URLSession(configuration: .default, delegate: self, delegateQueue: .main).webSocketTask(with: url)
			self.task.resume()
		}
	}
	
	func disconnect() {
		self.task.cancel(with: .goingAway, reason: "Closing connexion".data(using: .utf8))
	}
	
	// MARK: - Private functions
	private func receive() {
		self.task.receive { _response in
			switch _response {
			case .success(let _msg):
				switch _msg {
				case .string(let text):
					self.delegate.onReceived?(dataReceived: text)
				default:
					break
				}
				
			case .failure(let error):
				self.delegate.onError?(error: error.localizedDescription)
			}
			
			self.receive()
		}
	}
	
	private func ping() {
		self.task.sendPing { _error in
			if _error != nil {
				self.delegate.onError?(error: "Failed to connect to server")
			} else {
				DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
					self.ping()
				}
			}
		}
	}
	
	func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
		self.delegate.onConnected?()
		self.ping()
		self.receive()
	}
	
	func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
		self.delegate.onDisconnected?()
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
		self.delegate.onError?(error: error?.localizedDescription ?? "")
	}
}
