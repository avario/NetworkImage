import Nuke
import SwiftUI

public struct NetworkImage: View {
	let url: URL

	@State private var image: UIImage?

	public init(url: URL) {
		self.url = url

		if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
			image = Self.previewImage(at: url)
		}
	}

	public var body: some View {
		Group {
			if image == nil {
				Rectangle()
                    .opacity(0)
			} else {
				Image(uiImage: image!)
					.resizable()
			}
		}
		.onAppear {
			guard self.image == nil else {
				return
			}

			ImagePipeline.shared.loadImage(with: self.url) { result in
				switch result {
				case .success(let response): self.image = response.image
				case .failure(let error): print(error)
				}
			}
		}
	}

	private static func previewImage(at url: URL) -> UIImage? {
		var assetName = url.absoluteString
		if let scheme = url.scheme {
			assetName = assetName.replacingOccurrences(of: "\(scheme)://", with: "")
		}

		guard assetName.isEmpty == false else {
			return nil
		}

		if let image = UIImage(named: assetName) {
			return image
		}

		let nextURL: URL

		guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			return nil
		}

		if var queryItems = urlComponents.queryItems,
			queryItems.isEmpty == false {
			queryItems.removeLast()

			if queryItems.isEmpty {
				urlComponents.queryItems = nil
			} else {
				urlComponents.queryItems = queryItems
			}

			guard let componentsURL = urlComponents.url else {
				return nil
			}

			nextURL = componentsURL

		} else {
			nextURL = url.deletingLastPathComponent()
		}

		return previewImage(at: nextURL)
	}
}
