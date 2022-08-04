//
//  Launch.swift
//  spacex
//
//  Created by SDE3 on 8/4/22.
//

import Foundation

struct Launch: Decodable, Hashable {
	let name: String
	let details: String?
	let rocketId: String
	let payloadIds: [String]
	let date: String
	let links: Links?

	enum CodingKeys: String, CodingKey {
		case name
		case details
		case rocketId = "rocket"
		case payloadIds = "payloads"
		case date = "date_utc"
		case links
	}
}

struct Links: Decodable, Hashable {
	let wikipedia: String?
	let youtubeId: String?
	let flickr: Flickr?
	let patch: Patch?

	enum CodingKeys: String, CodingKey {
		case wikipedia
		case youtubeId = "youtube_id"
		case flickr
		case patch
	}
}

struct Patch: Decodable, Hashable {
	let large: String?
}

struct Flickr: Decodable, Hashable {
	let original: [String]?
}
