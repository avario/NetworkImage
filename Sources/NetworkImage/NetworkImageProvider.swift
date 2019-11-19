import Combine
import Foundation
import UIKit

protocol NetworkImageProvider {
    func imagePublisher(for url: URL) -> AnyPublisher<UIImage, Error>
}
