//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct SettingsFormStyle: FormStyle {
    func makeBody(configuration: Configuration) -> some View {
        ForEach(sections: configuration.content) { configuration in
            GroupBox {
                configuration.content
            }
            .background(.red)
        }
    }
}

extension FormStyle where Self == SettingsFormStyle {
    @MainActor static var settings: SettingsFormStyle {
        SettingsFormStyle()
    }
}
