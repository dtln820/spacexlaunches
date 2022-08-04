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

final class FetchService {

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

	func fetchRocketData(rocketId: String) -> AnyPublisher<Rocket, APIError> {
		guard let url = URL(string: "https://api.spacexdata.com/v4/rockets/\(rocketId)") else {
			return Fail(error: APIError.invalidRequestError("URL invalid")).eraseToAnyPublisher()
		}

		return URLSession.shared.dataTaskPublisher(for: url)
			.map { $0.data }
			.decode(type: Rocket.self, decoder: JSONDecoder())
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

	func fetchPayloadData(payloadIds: [String]) -> AnyPublisher<PayloadContainer, APIError> {
		guard let url = URL(string: "https://api.spacexdata.com/v4/payloads/query") else {
			return Fail(error: APIError.invalidRequestError("URL invalid")).eraseToAnyPublisher()
		}

		let requestModel = FetchPayloadRequestModel(payloadIds: payloadIds)
		guard let data = try? JSONEncoder().encode(requestModel) else {
			return Fail(error: APIError.invalidRequestError("Failed to encode request model")).eraseToAnyPublisher()
		}

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = [
			"Content-Type": "application/json"
		]
		request.httpBody = data

		return URLSession.shared.dataTaskPublisher(for: request)
			.map { $0.data }
			.decode(type: PayloadContainer.self, decoder: JSONDecoder())
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

struct FetchPayloadRequestModel: Encodable {
	let query: Query

	init(payloadIds: [String]) {
		self.query = Query(idCondition: Query.IdCondition(condition: payloadIds))
	}

	struct Query: Encodable {
		let idCondition: IdCondition

		struct IdCondition: Encodable {
			let condition: [String]

			enum CodingKeys: String, CodingKey {
				case condition = "$in"
			}
		}

		enum CodingKeys: String, CodingKey {
			case idCondition = "_id"
		}
	}
}

