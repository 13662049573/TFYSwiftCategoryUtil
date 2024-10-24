import SwiftUI

@available(iOS 13.0, *)
extension Array: @retroactive View where Element: View {
    public var body: some View {
        ForEach(indices, id: \.self) { self[$0] }
    }
}
