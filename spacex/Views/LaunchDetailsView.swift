//
//  LaunchDetailsView.swift
//  spacex
//
//  Created by SDE3 on 8/4/22.
//

import SwiftUI
import WebKit
import Combine

struct LaunchDetailsView: View {

	@ObservedObject private var viewModel: LaunchDetailsViewModel
	@Environment(\.openURL) private var openURL

	init(launch: Launch) {
		viewModel = LaunchDetailsViewModel(launch)
	}

	var body: some View {
		VStack(alignment: .leading) {
			VideoView(youtubeId: viewModel.youtubeId)
				.frame(minHeight: 0, maxHeight: 240)
				.cornerRadius(16)
				.padding(.horizontal, 24)
			Text(viewModel.formattedDate)
				.frame(maxWidth: .infinity, alignment: .center)
			Text(viewModel.details)
				.padding(.top, 8)
				.padding(.horizontal, 24)
			Text("Rocket name: \(viewModel.rocketViewModel?.name ?? "Unknown")")
				.padding(.top, 32)
				.frame(maxWidth: .infinity, alignment: .center)
			Text("Payload mass: \(viewModel.payloadViewModel?.totalKg ?? "0.0") kg")
				.frame(maxWidth: .infinity, alignment: .center)
			Spacer()
			Button("Wikipedia") {
				if let wikiUrl = URL(string: viewModel.wikipediaLink) {
					openURL(wikiUrl)
				}
			}
			.foregroundColor(viewModel.wikipediaLink.isEmpty ? .gray : .blue)
			.frame(maxWidth: .infinity, alignment: .center)
		}
		.navigationBarTitle(viewModel.name)
		.navigationBarTitleDisplayMode(.inline)
		.onAppear {
			viewModel.fetchRocketData()
			viewModel.fetchPayloadData()
		}
	}
}

struct LaunchDetailsView_Previews: PreviewProvider {

	static let launchPreview = Launch(
		name: "Test Launch",
		details: "Some important details",
		rocketId: "thisrocket",
		payloadIds: ["blabla"],
		date: "2021-12-18T12:41:40.000Z",
		links: nil)

	static var previews: some View {
		LaunchDetailsView(launch: launchPreview)
	}
}

