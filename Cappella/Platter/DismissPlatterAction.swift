//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct DismissPlatterAction {
    private weak var platterWindow: PlatterWindow?

    init() {
        self.platterWindow = nil
    }

    init(for platterWindow: PlatterWindow) {
        self.platterWindow = platterWindow
    }

    @MainActor
    func callAsFunction() {
        guard let platterWindow else { return }

        platterWindow.orderOut(nil)
    }
}

extension EnvironmentValues {
    @Entry var dismissPlatter = DismissPlatterAction()
}
