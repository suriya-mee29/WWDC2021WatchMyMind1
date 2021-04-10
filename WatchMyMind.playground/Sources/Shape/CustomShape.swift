
import SwiftUI

// MARK: - COUSTOM SHAPE
public struct CustomShape: Shape {
    public init (){}
    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomRight,.topRight], cornerRadii: CGSize(width: 90, height: 90))
        return Path(path.cgPath)
    }
}
