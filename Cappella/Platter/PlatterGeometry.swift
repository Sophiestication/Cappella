//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

@Observable
final class PlatterGeometry: Sendable {
    let containerSize: CGSize

    let headerDimension: CGFloat
    let footerDimension: CGFloat

    init(
        containerSize: CGSize = .zero,
        headerDimension: CGFloat = 60.0,
        footerDimension: CGFloat = 60.0
    ) {
        self.containerSize = containerSize

        self.headerDimension = headerDimension
        self.footerDimension = footerDimension
    }
}

extension EnvironmentValues {
    @Entry var platterGeometry = PlatterGeometry()
}
