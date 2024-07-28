//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct ArtworkView: View {
    var body: some View {
        Image("JewelcaseEmpty")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 280.0)
    }
}

#Preview {
    ArtworkView()
}
