import UIKit

extension UITraitCollection {

    /// Creates the provided image with traits from the receiver.
    func makeImage(_ makeImage: @autoclosure () -> UIImage) -> UIImage {
        var image: UIImage!
        performAsCurrent {
            image = makeImage()
        }
        return image
    }

}
