//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

@Observable
class PlatterProxy {
    private weak var platterWindow: PlatterWindow?
    private weak var menuExtra: MenuBarExtra?

    init() {
        self.platterWindow = nil
    }

    init(for platterWindow: PlatterWindow) {
        self.platterWindow = platterWindow
        self.menuExtra = nil
    }

    init(for menuExtra: MenuBarExtra) {
        self.platterWindow = nil
        self.menuExtra = menuExtra
    }

    @MainActor
    var isPresented: Bool {
        guard let platterWindow else { return false }
        return platterWindow.isVisible
    }
}

extension EnvironmentValues {
    @Entry var platterProxy: PlatterProxy? = nil
}
