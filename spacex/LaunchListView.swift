//
//  ContentView.swift
//  spacex
//
//  Created by SDE3 on 8/3/22.
//

import SwiftUI
import Combine

struct LaunchListView: View {

	@ObservedObject private var viewModel = LaunchListViewModel()

    var body: some View {
		NavigationView {
			List(viewModel.launchViewModels, id: \.self) { launchViewModel in
				ZStack {
					NavigationLink(
						destination: LaunchDetailsView()) {
							EmptyView()
						}
						.opacity(0)
					HStack {
						Spacer()
						VStack {
							LaunchImageView(urlString: launchViewModel.imageUrl)
								.padding(.top, 12)
							HStack {
								Text(launchViewModel.name)
									.padding(.bottom, 12)
								Spacer()
								Text(launchViewModel.formattedDate)
									.padding(.bottom, 12)
							}
						}
						Spacer()
					}
					.overlay {
						RoundedRectangle(cornerRadius: 12)
							.stroke(.blue, lineWidth: 1)
					}
					.padding(.top, 5)
					.padding(.bottom, 5)
				}
				.listRowSeparator(.hidden)
			}
			.onAppear {
				self.viewModel.fetchPastLaunches()
			}
			.navigationBarTitle("SpaceX")
			.navigationBarTitleDisplayMode(.inline)
		}
    }
}

struct LaunchListView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchListView()
    }
}

struct LaunchImageView: View {
	@StateObject var imageLoader: ImageLoaderService
	//	@ObservedObject var imageLoader: ImageLoaderService

	init(urlString: String) {
		_imageLoader = StateObject(wrappedValue: ImageLoaderService(urlString: urlString))
		//		imageLoader = ImageLoaderService(urlString: urlString)
	}

	var body: some View {
		content
			.onAppear(perform: imageLoader.loadImage)
			.onDisappear(perform: imageLoader.cancel)
	}

	private var content: some View {
		Group {
			if imageLoader.image != nil {
				Image(uiImage: imageLoader.image!)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.cornerRadius(20)
					.frame(width: 300, height: 150)
			} else {
				Text("Loading...")
					.frame(width: 300, height: 150)
			}
		}
	}
}

class LaunchListViewModel: ObservableObject {

	private let fetchService = FetchLaunchService()

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

	init(_ launch: Launch) {
		self.launch = launch
	}

	var imageUrl: String {
		let flickrImage = launch.links?.flickr?.original?.first
		let patchImage = launch.links?.patch?.large

		return flickrImage ?? patchImage ?? ""
	}
}

