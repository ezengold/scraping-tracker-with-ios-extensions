//
//  FetchWidgetEntry.swift
//  TrackerApp
//
//  Created by ezen on 12/08/2024.
//

import Foundation
import SwiftSoup

protocol FetchItem {
	
	func execute(at url: String) async -> TrackedItem
}

struct FetchItemUseCase: FetchItem {
	
	var api: ContentApi
	
	func execute(at url: String) async -> TrackedItem {
		do {
			let _response = try await api.fetchContent(at: url)
			
			guard let str = _response, !str.isEmpty else {
				return TrackedItem()
			}
		
			let doc = try SwiftSoup.parse(str)
			
			let group = try doc.select(".product-price-block .as-h4.text-normal")
			
			let elements = (try group.text()).split(separator: "   ")
			
			var realPrice = (elements.first?.description ?? "0").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "")
			var realPriceNumber = getPrice(from: realPrice)
			
			var currentPrice = (elements.last?.description ?? "0").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "")
			var currentPriceNumber = getPrice(from: currentPrice)
			
			// print((group.count, realPrice, realPriceNumber, currentPrice, currentPriceNumber))
			
			var discount: Int = 0
			if realPriceNumber != 0 {
				discount = Int(floor((1.0 - Float(currentPriceNumber) / Float(realPriceNumber)) * 100))
			}
			
			return TrackedItem(price: currentPrice, discount: discount.description)
		} catch {
			print(error.localizedDescription)
			return TrackedItem()
		}
	}
	
	func getPrice(from value: String) -> Int {
		let _value = value.components(separatedBy: .whitespacesAndNewlines).joined()
		let _matches = _value.matches(of: /[0-9]/)
		let _output = _matches.map({ String($0.description) }).joined()
		return Int(_output) ?? 0
	}
}
