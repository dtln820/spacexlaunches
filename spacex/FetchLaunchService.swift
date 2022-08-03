//
//  FetchService.swift
//  spacex
//
//  Created by SDE3 on 8/3/22.
//

import Foundation
import Combine

enum APIError: Error, LocalizedError {
	case unknown
	case apiError(String)
	case invalidRequestError(String)
	case transportError(Error)

	var errorDescription: String? {
		switch self {
		case .unknown:
			return "Unknown error"
		case .apiError(let reason):
			return reason
		case .invalidRequestError(let reason):
			return reason
		case .transportError(let error):
			return error.localizedDescription
		}
	}
}

final class FetchLaunchService {

	func fetchPastLaunches() -> AnyPublisher<[Launch], APIError> {
		guard let url = URL(string: "https://api.spacexdata.com/v5/launches/past") else {
			return Fail(error: APIError.invalidRequestError("URL invalid")).eraseToAnyPublisher()
		}

		return URLSession.shared.dataTaskPublisher(for: url)
			.map { $0.data }
			.decode(type: [Launch].self, decoder: JSONDecoder())
			.mapError { error in
				if let error = error as? APIError {
					return error
				} else {
					return APIError.apiError(error.localizedDescription)
				}
			}
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

}

struct Launch: Decodable, Hashable {
	let name: String
	let date: String
	let links: Links?

	enum CodingKeys: String, CodingKey {
		case name
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

