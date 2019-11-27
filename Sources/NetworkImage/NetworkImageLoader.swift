import Combine
import Foundation
import UIKit

public final class NetworkImageLoader: ObservableObject {
    public enum State {
        case loading
        case error(URLError)
        case success(UIImage)
    }

    @Published public var state: State = .loading

    private let url: URL

    init(url: URL) {
        self.url = url
    }

    private var cancellable: Cancellable?

    func load() {
        guard cancellable == nil else {
            return
        }

        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil else {
            loadPreviewImage()
            return
        }

        cancellable = URLSession.shared
            .dataTaskPublisher(for: url)
            .map { State.success(UIImage(data: $0.data)!) }
            .catch { Just(State.error($0)) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
    }

    private func loadPreviewImage() {
        var urlString = url.absoluteString
        if let scheme = url.scheme {
            urlString = urlString.replacingOccurrences(of: "\(scheme)://", with: "")
        }

        guard let assetURL = URL(string: urlString) else {
            state = .error(URLError(.cancelled))
            return
        }

        func previewImage(at url: URL) -> UIImage? {
            let assetName = url.absoluteString

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

        guard let image = previewImage(at: assetURL) else {
            print("⚠️ Preview image not found for: \(assetURL.absoluteString)")
            state = .error(URLError(.cancelled))
            return
        }

        state = .success(image)
    }

    func cancel() {
        cancellable?.cancel()
    }
}
