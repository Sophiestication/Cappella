//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct AboutBoxView: View {
    @Environment(\.pixelLength) var pixelLength

    var body: some View {
        VStack(spacing: 0.0) {
           Image("SecretAboutBox")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 600.0, alignment: .top)

            Text("""
            CoverSutra **Version:** 4.0 (Cappella) **Copyright** © 2024 Sophia Teutschler. All rights reserved. This app and its contents are protected under copyright law. Unauthorized reproduction or distribution is prohibited. **Credits** App Icon: Michael Flarup Teaser Artwork: Anthony Piraino (The Iconfactory) Special Thanks to: The Iconfactory Team, Apple Developer Relations **Acknowledgements** SwiftUI is a registered trademark of Apple Inc. All third-party trademarks are the property of their respective owners. **Disclaimer** This software is provided 'as-is', without any express or implied warranty. In no event shall the author be held liable for any damages arising from the use of this software.
            """)
            .padding()
            .background(.black)
            .font(.system(size: 14.0, design: .rounded))
        }
        .background {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
        }
        .frame(width: 600.0)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    AboutBoxView()
        .environment(\.artworkProvider, PreviewArtworkProvider())
}
