//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct ApplicationMenuButton: View {
    var body: some View {
        Menu {
            Button("Play", action: {})
            Button("Next Track", action: {})
            Button("Previous Track", action: {})

            Divider()

            Menu("Repeat") {
                Button("Off", action: {})
                Button("All", action: {})
                Button("One", action: {})
            }

            Menu("Shuffle") {
                Button("On", action: {})
                Button("Off", action: {})
                Divider()
                Button("Songs", action: {})
                Button("Albums", action: {})
                Button("Groupings", action: {})
            }

            Divider()

            Button("Settings…", action: {})

            Divider()

            Button("About \(applicationName)", action: {})

            Divider()

            Button("Quit \(applicationName)", action: {})
        } label: {
            Image("settingsTemplate")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24.0)
                .padding(.trailing, 15.0)
        }
        .buttonStyle(.plain)
    }

    private var applicationName: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleDisplayName"
        ) as! String
    }
}

#Preview {
    ApplicationMenuButton()
        .scenePadding()
}
