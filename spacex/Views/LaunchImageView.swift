//
//  LaunchImageView.swift
//  spacex
//
//  Created by SDE3 on 8/4/22.
//

import Foundation
import Combine
import SwiftUI

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
