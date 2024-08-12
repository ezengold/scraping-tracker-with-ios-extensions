//
//  ContentApiImpl.swift
//  TrackerApp
//
//  Created by ezen on 12/08/2024.
//

import Foundation

final class ContentApiImpl: ContentApi {
	
	static let shared = ContentApiImpl()
	
	func fetchContent(at url: String) async throws -> String? {
		if let _url = URL(string: url) {
			var _request = URLRequest(url: _url)
			_request.httpMethod = "GET"
			_request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
			_request.setValue("text/html; charset=utf-8", forHTTPHeaderField: "Content-Type")
			
			let (_data, _) = try await URLSession.shared.data(for: _request)
			
			return String(data: _data, encoding: .utf8)
		}
		return nil
	}
}
