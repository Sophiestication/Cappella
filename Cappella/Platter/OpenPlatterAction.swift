//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct OpenPlatterAction {
    private weak var platterWindow: PlatterWindow?

    init() {
        self.platterWindow = nil
    }

    init(for platterWindow: PlatterWindow) {
        self.platterWindow = platterWindow
    }

    @MainActor
    func callAsFunction() {
        if let platterWindow {
            platterWindow.orderFront(nil, animated: true)
        }
    }
}

extension EnvironmentValues {
    @Entry var openPlatter = OpenPlatterAction()
}
