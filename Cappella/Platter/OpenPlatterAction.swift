//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct OpenPlatterAction {
    private weak var platterWindow: PlatterWindow?
    private weak var menuExtra: MenuBarExtra?

    init() {
        self.platterWindow = nil
        self.menuExtra = nil
    }

    init(for platterWindow: PlatterWindow) {
        self.platterWindow = platterWindow
    }

    init(for menuExtra: MenuBarExtra) {
        self.platterWindow = nil
        self.menuExtra = menuExtra
    }

    @MainActor
    func callAsFunction() {
        if let menuExtra {
            menuExtra.windowShown = true
        } else if let platterWindow {
            platterWindow.makeKeyAndOrderFront(nil)
        }
    }
}

extension EnvironmentValues {
    @Entry var openPlatter = OpenPlatterAction()
}
