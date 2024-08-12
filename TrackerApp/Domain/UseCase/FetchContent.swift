//
//  FetchContent.swift
//  TrackerApp
//
//  Created by ezen on 12/08/2024.
//

import Foundation

protocol FetchContent {
	
	func execute(at url: String) async throws -> String
}

struct FetchContentUseCase: FetchContent {
	
	var api: ContentApi
	
	func execute(at url: String) async throws -> String {
		let _response = try await api.fetchContent(at: url)
		return _response ?? ""
	}
}
