//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

@Observable
final class PlatterGeometry: Sendable {
    let containerSize: CGSize

    init(containerSize: CGSize = .zero) {
        self.containerSize = containerSize
    }
}

extension EnvironmentValues {
    @Entry var platterGeometry = PlatterGeometry()
}
