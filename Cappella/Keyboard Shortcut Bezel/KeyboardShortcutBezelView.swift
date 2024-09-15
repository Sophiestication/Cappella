//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct KeyboardShortcutBezelView : View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8.0, style: .continuous)
            .fill(.teal)
            .opacity(0.50)
            .frame(width: 200.0, height: 200.0)
    }
}

#Preview {
    KeyboardShortcutBezelView()
}
