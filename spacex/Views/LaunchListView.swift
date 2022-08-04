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
						destination: LaunchDetailsView(launch: launchViewModel.getLaunch())) {
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

