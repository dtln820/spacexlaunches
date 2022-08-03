//
//  ImageLoaderService.swift
//  spacex
//
//  Created by SDE3 on 8/3/22.
//

import Foundation
import SwiftUI
import Combine

final class ImageLoaderService: ObservableObject {
	@Published var image: UIImage?
	private var cancellable: AnyCancellable?
	private let url: URL?
	private var cache = ImageCache.shared

	init(urlString: String) {
		if let safeUrl = URL(string: urlString) {
			url = safeUrl
		} else {
			url = nil
		}
	}

	func loadImage() {
		guard let safeUrl = url else {
			image = UIImage(named: "ic_no_image")
			return
		}

		if let image: UIImage = cache[safeUrl.absoluteString] {
			self.image = image
			return
		}

		cancellable = URLSession.shared
			.dataTaskPublisher(for: safeUrl)
			.map { UIImage(data: $0.data) }
			.replaceError(with: nil)
			.handleEvents(receiveOutput: { self.cache[safeUrl.absoluteString] = $0 })
			.receive(on: DispatchQueue.main)
			.assign(to: \.image, on: self)

//		cancellable = URLSession.shared.dataTaskPublisher(for: safeUrl)
//			.map { UIImage(data: $0.data) }
//			.replaceError(with: nil)
//			.receive(on: DispatchQueue.main)
//			.sink { [weak self] in
//				if let newImage = $0 {
//					self?.image = newImage
//				} else {
//					self?.image = UIImage(named: "ic_no_image")
//				}
//			}
	}

	func cancel() {
		cancellable?.cancel()
	}

//	deinit {
//		cancel()
//	}

}

