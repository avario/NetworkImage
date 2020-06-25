import Nuke
import SwiftUI

public struct NetworkImage: View {
	let url: URL

	@State private var image: UIImage?

	public init(url: URL) {
		self.url = url
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

			if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
				self.image = Self.previewImage(at: self.url)
				return
			}

			ImagePipeline.shared.loadImage(with: self.url) { result in
				if case .success(let response) = result {
					self.image = response.image
				}
			}
		}
	}

	private static func previewImage(at url: URL) -> UIImage? {
		if let scheme = url.scheme {
			guard let schemelessURL = URL(string: url.absoluteString.replacingOccurrences(of: "\(scheme)://", with: "")) else {
				return nil
			}
			return previewImage(at: schemelessURL)
		}

		let assetName = url.absoluteString

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

		guard nextURL.lastPathComponent != "." else {
			return nil
		}

		return previewImage(at: nextURL)
	}
}
