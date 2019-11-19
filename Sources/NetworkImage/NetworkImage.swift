import Combine
import SwiftUI

public struct NetworkImage: View {
    @Environment(\.networkImagePreviewMode) private var previewMode: NetworkImagePreviewMode

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

public enum NetworkImagePreviewMode {
    case automatic
    case always
    case never
}

extension NetworkImagePreviewMode: EnvironmentKey {
    public static let defaultValue: NetworkImagePreviewMode = .automatic
}

public extension EnvironmentValues {
    var networkImagePreviewMode: NetworkImagePreviewMode {
        get {
            return self[NetworkImagePreviewMode.self]
        }
        set {
            self[NetworkImagePreviewMode.self] = newValue
        }
    }
}
