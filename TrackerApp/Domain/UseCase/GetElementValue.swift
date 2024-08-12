//
//  GetElementValue.swift
//  TrackerApp
//
//  Created by ezen on 12/08/2024.
//

import Foundation

protocol GetElementValue {
	
	func execute(from documentStr: String) throws -> String
}

struct GetElementValueUseCase: GetElementValue {
	
	func execute(from documentStr: String) throws -> String {
		return ""
	}
}

