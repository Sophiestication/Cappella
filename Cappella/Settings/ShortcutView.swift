//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct ShortcutView: View {
    var body: some View {
        Button(action: {

        }, label: {
            HStack {
                Text("Shift + 1")
                Image(systemName: "xmark.circle.fill")
            }
        })
    }
}

#Preview {
    ShortcutView()
}
