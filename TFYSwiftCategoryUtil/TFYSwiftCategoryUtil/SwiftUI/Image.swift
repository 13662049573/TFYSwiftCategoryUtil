import SwiftUI

@available(iOS 13.0, *)
public extension Image {
    
    /// Initialize with a default image
    /// - Parameters:
    ///   - name: primary image name
    ///   - defaultImage: default image name
    init(_ name: String, defaultImage: String) {
        if let img = UIImage(named: name) {
            self.init(uiImage: img)
        } else {
            self.init(defaultImage)
        }
    }

    /// Initialize with default system image
    /// - Parameters:
    ///   - name: primary image name
    ///   - defaultSystemImage: default image name
    init(_ name: String, defaultSystemImage: String) {
        if let img = UIImage(named: name) {
            self.init(uiImage: img)
        } else {
            self.init(systemName: defaultSystemImage)
        }
    }
    
    /// Create a resizable image with CGSize
    /// - Parameter size: CGSize
    /// - Returns: View
    func icon(with size: CGSize) -> some View {
        self.renderingMode(.template)
            .resizable()
            .frame(width: size.width, height: size.height)
    }
    
}
