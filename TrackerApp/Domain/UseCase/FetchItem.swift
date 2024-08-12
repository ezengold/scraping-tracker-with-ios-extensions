//
//  FetchWidgetEntry.swift
//  TrackerApp
//
//  Created by ezen on 12/08/2024.
//

import Foundation
import SwiftSoup

protocol FetchItem {
	
	func execute(at url: String, withSelector selector: String) async -> TrackedItem
}

struct FetchItemUseCase: FetchItem {
	
	var api: ContentApi
	
	func execute(at url: String, withSelector selector: String) async -> TrackedItem {
		do {
			let _response = try await api.fetchContent(at: url)
			
			guard let str = _response, !str.isEmpty else {
				return TrackedItem()
			}
			
			let doc = try SwiftSoup.parse(str)
			
			let group = try doc.select(selector)
			
			guard let element = group.first() else {
				return TrackedItem()
			}
			
//			let _value = try element.text()
			let _value = (try element.text()).split(separator: ":").last?.description ?? "0"
			
			return TrackedItem(price: _value, cents: Int.random(in: 10...99).description, discount: Int.random(in: 10...30).description) // TODO: Review later
		} catch {
			return TrackedItem()
		}
	}
}
