import Combine
import SwiftUI

public struct NetworkImage: View {
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
        .onAppear { self.imageLoader.load() }
        .onDisappear(perform: imageLoader.cancel)
    }
}
