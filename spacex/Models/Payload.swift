//
//  Payload.swift
//  spacex
//
//  Created by SDE3 on 8/4/22.
//

import Foundation

struct Payload: Decodable {
	let mass: Double?

	enum CodingKeys: String, CodingKey {
		case mass = "mass_kg"
	}
}

struct PayloadContainer: Decodable {
	let payloads: [Payload]

	enum CodingKeys: String, CodingKey {
		case payloads = "docs"
	}
}
