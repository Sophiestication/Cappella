//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct SettingsGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
    }
}

extension GroupBoxStyle where Self == SettingsGroupBoxStyle {
    @MainActor static var settings: SettingsGroupBoxStyle {
        SettingsGroupBoxStyle()
    }
}
