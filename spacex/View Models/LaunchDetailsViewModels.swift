//
//  LaunchDetails.swift
//  spacex
//
//  Created by SDE3 on 8/4/22.
//

import SwiftUI
import Combine

class LaunchDetailsViewModel: ObservableObject {

	private let fetchService = FetchService()

	var cancellableSet = Set<AnyCancellable>()

	private let launch: Launch

	init(_ launch: Launch) {
		self.launch = launch
	}

	@Published var rocketViewModel: RocketViewModel?
	@Published var payloadViewModel: PayloadViewModel?

	var name: String {
		launch.name
	}

	var wikipediaLink: String {
		launch.links?.wikipedia ?? ""
	}

	var details: String {
		launch.details ?? "No description available"
	}

	var youtubeId: String {
		launch.links?.youtubeId ?? ""
	}

	var formattedDate: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
		dateFormatter.timeZone = TimeZone(identifier: "UTC")
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		let date = dateFormatter.date(from: launch.date)

		if let date = date {
			return DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none)
		}

		return "Failed"
	}

	func fetchRocketData() {
		fetchService.fetchRocketData(rocketId: launch.rocketId).sink(receiveCompletion: { completion in
			switch completion {
			case .finished:
				break
			case .failure(let error):
				print(error.localizedDescription)
			}
		}, receiveValue: { rocket in
			self.rocketViewModel = RocketViewModel(rocket)
		})
		.store(in: &cancellableSet)
	}

	func fetchPayloadData() {
		guard launch.payloadIds.count > 0 else { return }

		fetchService.fetchPayloadData(payloadIds: launch.payloadIds).sink(receiveCompletion: { completion in
			switch completion {
			case .finished:
				break
			case .failure(let error):
				print(error.localizedDescription)
			}
		}, receiveValue: { payloadsContainer in
			self.payloadViewModel = PayloadViewModel(payloadsContainer.payloads)
		})
		.store(in: &cancellableSet)
	}
}

struct RocketViewModel {
	private let rocket: Rocket

	var name: String {
		return rocket.name
	}

	init(_ rocket: Rocket) {
		self.rocket = rocket
	}
}

struct PayloadViewModel {
	private let payloads: [Payload]

	var totalKg: String {
		let totalMass = payloads.reduce(into: 0) { prevResult, element in
			prevResult += (element.mass ?? 0.0)
		}

		return String(format: "%.1f", totalMass)
	}

	init(_ payloads: [Payload]) {
		self.payloads = payloads
	}
}
