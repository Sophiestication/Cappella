//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct AuthorizationView: View {
    var body: some View {
        Button(action: {
            Task {
                await MusicAuthorization.request()
            }
        }, label: {
            Text("Authorize")
        })
    }
}

#Preview {
    AuthorizationView()
        .frame(width: 400.0, height: 480.0)
}
