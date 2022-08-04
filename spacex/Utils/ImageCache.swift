//
//  ImageCache.swift
//  spacex
//
//  Created by SDE3 on 8/3/22.
//

import Foundation
import SwiftUI

class ImageCache {

	static let shared = ImageCache()
	private var cache: NSCache = NSCache<NSString, UIImage>()

	subscript(key: String) -> UIImage? {
		get {
			cache.object(forKey: key as NSString)
		}
		set(image) {
			image == nil ? self.cache.removeObject(forKey: (key as NSString)) : self.cache.setObject(image!, forKey: (key as NSString))
		}
	}
}

