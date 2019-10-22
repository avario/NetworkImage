//
//  File.swift
//  
//
//  Created by Avario Babushka on 18/10/19.
//

import Foundation
import NetworkKit
import Combine
import UIKit

final public class NetworkImageLoader: ObservableObject {

	public enum State {
		case loading
		case error(NetworkError<Void>)
		case success(UIImage)
	}

	@Published public var state: State = .loading

    private struct ImageRequest: NetworkRequest {
        let path: String
        let method: HTTPMethod = .get

        typealias Response = UIImage
    }

    private class ImageNetwork: Network {
        let baseURL: URL

        internal init(baseURL: URL) {
            self.baseURL = baseURL
        }
    }

    private let imageRequest: ImageRequest
    private let imageNetwork: ImageNetwork

    init(url: URL) {
        imageRequest = ImageRequest(path: url.lastPathComponent)
        imageNetwork = ImageNetwork(baseURL: url.deletingLastPathComponent())
	}

	private var cancellable: Cancellable?

	func load(previewMode: NetworkPreviewMode = .noPreview) {

        cancellable = imageNetwork.preview(mode: previewMode)
            .request(imageRequest)
            .map { .success($0) }
            .catch { Just(.error($0)) }
			.assign(to: \.state, on: self)
	}

	func cancel() {
		cancellable?.cancel()
	}

}
