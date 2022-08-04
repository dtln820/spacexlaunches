//
//  LaunchListViewModels.swift
//  spacex
//
//  Created by SDE3 on 8/4/22.
//

import Foundation
import Combine

class LaunchListViewModel: ObservableObject {

	private let fetchService = FetchService()

	@Published var launchViewModels = [LaunchViewModel]()

	var cancellable: AnyCancellable?

	func fetchPastLaunches() {
		cancellable = fetchService.fetchPastLaunches().sink(receiveCompletion: { completion in
			switch completion {
			case .finished:
				break
			case .failure(let error):
				print(error.localizedDescription)
			}
		}, receiveValue: { launches in
			self.launchViewModels = launches.reversed().map { LaunchViewModel($0) }
		})
	}
}

struct LaunchViewModel: Hashable {
	private let launch: Launch

	func getLaunch() -> Launch {
		return launch
	}

	var name: String {
		return launch.name
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

	var imageUrl: String {
		let flickrImage = launch.links?.flickr?.original?.first
		let patchImage = launch.links?.patch?.large

		return flickrImage ?? patchImage ?? ""
	}

	init(_ launch: Launch) {
		self.launch = launch
	}
}
