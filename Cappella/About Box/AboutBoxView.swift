//
// MIT License
//
// Copyright (c) 2006-2024 Sophiestication Software, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
