//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterMenuLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        PlatterMenuItem {
            HStack {
                configuration.icon

                VStack(alignment: .leading) {
                    configuration.title
                        .menuItemTextShadow()
                }
            }
        }
    }
}
