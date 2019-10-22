//
//  Created by Avario Babushka on 1/10/19.
//  Copyright © 2019 Avario Babushka. All rights reserved.
//

import SwiftUI
import Combine
import NetworkKit

public struct NetworkImage: View {
	
	@Environment(\.networkImagePreviewMode) private var previewMode: NetworkPreviewMode
	
	@ObservedObject private var imageLoader: NetworkImageLoader

	public init(url: URL) {
        imageLoader = NetworkImageLoader(url: url)
	}
	
	public var body: some View {
		ZStack { () -> AnyView in // Must wrap in AnyView until SwiftUI support switch statements.
			switch imageLoader.state {
			case .loading, .error:
				return AnyView(EmptyView())

			case .success(let image):
				return AnyView(
					Image(uiImage: image)
						.resizable()
				)
			}
		}
		.onAppear { self.imageLoader.load(previewMode: self.previewMode) }
		.onDisappear(perform: imageLoader.cancel)
	}
}

extension NetworkPreviewMode: EnvironmentKey {
	public static let defaultValue: NetworkPreviewMode = .automatic
}

public extension EnvironmentValues {
	var networkImagePreviewMode: NetworkPreviewMode {
		get {
			return self[NetworkPreviewMode.self]
		}
		set {
			self[NetworkPreviewMode.self] = newValue
		}
	}
}
