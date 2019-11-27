import KingfisherSwiftUI
import SwiftUI

public struct NetworkImage: View {
    let url: URL

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        Group {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
                Image(uiImage: previewImage ?? UIImage())
            } else {
                KFImage(url)
            }
        }
    }

    private var previewImage: UIImage? {
        var urlString = url.absoluteString
        if let scheme = url.scheme {
            urlString = urlString.replacingOccurrences(of: "\(scheme)://", with: "")
        }

        guard let assetURL = URL(string: urlString) else {
            return nil
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

        return previewImage(at: assetURL)
    }
}
