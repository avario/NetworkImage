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
		case error(NetworkError)
		case success(UIImage)
	}

	@Published public var state: State = .loading

    let request: URLRequest

    init(request: URLRequest) {
		self.request = request
	}

	private var cancellable: Cancellable?

	func load(previewMode: NetworkPreviewMode = .noPreview) {

        cancellable = NetworkKit
            .request(request, previewMode: previewMode)
            .tryMap {
                guard let image = UIImage(data: $0) else {
                    throw NetworkError.unknown
                }
                return .success(image)
            }
			.replaceError(with: .error(.unknown))
			.receive(on: DispatchQueue.main)
			.assign(to: \.state, on: self)
	}

	func cancel() {
		cancellable?.cancel()
	}

}
