//
//  ContentApi.swift
//  TrackerApp
//
//  Created by ezen on 12/08/2024.
//

import Foundation

protocol ContentApi {
	
	func fetchContent(at url: String) async throws -> String?
}
