//
//  VideoView.swift
//  spacex
//
//  Created by SDE3 on 8/4/22.
//

import SwiftUI
import WebKit

struct VideoView: UIViewRepresentable {

	let youtubeId: String

	func makeUIView(context: Context) -> WKWebView {
		return WKWebView()
	}

	func updateUIView(_ uiView: WKWebView, context: Context) {
		guard let url = URL(string: "https://youtube.com/embed/\(youtubeId)") else { return }

		uiView.scrollView.isScrollEnabled = false
		uiView.load(URLRequest(url: url))
	}
}
