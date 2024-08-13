//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import AppKit

struct PlatterView<Content>: View where Content: View {
    private let content: () -> Content

    @State private var headerContent = PlatterHeaderContentPreferenceKey.defaultValue
    @State private var scrollGeometry: ScrollGeometry? = nil

    init(
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                ZStack(alignment: .top) {
                    makeBackgroundView()
                        .frame(
                            width: contentSize(for: geometry).width,
                            height: contentSize(for: geometry).height
                        )
                        .offset(
                            x: 0.0,
                            y: verticalBackgroundOffset(geometry: geometry)
                        )

                    VStack(spacing: 0.0) {
                        makeHeaderView()
                            .offset(
                                x: 0.0,
                                y: verticalBackgroundOffset(geometry: geometry)
                            )
                            .zIndex(1)

                        content()
                    }
                }
            }

            .onScrollGeometryChange(for: ScrollGeometry.self) { scrollGeometry in
                scrollGeometry
            } action: { oldValue, newValue in
                scrollGeometry = newValue
            }

            .onPreferenceChange(PlatterHeaderContentPreferenceKey.self) { value in
                headerContent = value
            }
        }
    }

    @ViewBuilder
    private func makeBackgroundView() -> some View {
        VisualEffectView(
            material: .underWindowBackground,
            blendingMode: .behindWindow,
            state: .active,
            cornerRadius: 16.0
        )

//        RoundedRectangle(cornerRadius: 16.0, style: .continuous)
//            .fill(Color.black)
    }

    @ViewBuilder
    private func makeHeaderView() -> some View {
        VStack {
            ForEach(headerContent) { header in
                header.content()
            }
        }
    }

    private func verticalBackgroundOffset(
        geometry: GeometryProxy
    ) -> CGFloat {
        guard let scrollGeometry else {
            return 0.0
        }

        let rect = scrollGeometry.bounds
        print("\(rect); \(scrollGeometry.contentSize); \(rect.maxY)")

        if rect.minY < 0.0 {
            return 0.0
        }

        let bottomOffset = rect.maxY - scrollGeometry.contentSize.height
        print("\(bottomOffset)")

        if bottomOffset > 0.0 {
            return scrollGeometry.bounds.minY - bottomOffset
        }

        return scrollGeometry.bounds.minY
    }

    private func contentSize(for geometry: GeometryProxy) -> CGSize {
        return CGSize(
            width: geometry.size.width - 0.0,
            height: geometry.size.height - 0.0)
    }
}

@Observable @MainActor
fileprivate final class PlatterContent: Identifiable, Equatable {
    let id: String
    let content: () -> AnyView

    init(id: String, content: @escaping () -> AnyView) {
        self.id = id
        self.content = content
    }

    nonisolated static func == (lhs: PlatterContent, rhs: PlatterContent) -> Bool {
        lhs.id == rhs.id
    }
}

fileprivate struct PlatterHeaderContentPreferenceKey: PreferenceKey {
    typealias Value = [PlatterContent]

    static let defaultValue: Value = []
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

struct PlatterContentPlacement {
    fileprivate let preferenceKey: PlatterHeaderContentPreferenceKey.Type

    static let header = PlatterContentPlacement(
        preferenceKey: PlatterHeaderContentPreferenceKey.self
    )

    //    static let footer = PlatterContentPlacement(
    //        preferenceKey: PlatterFooterContentPreferenceKey.self
    //    )
}

extension View {
    func platterContent<Content: View>(
        id: String,
        placement: PlatterContentPlacement,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.preference(
            key: placement.preferenceKey,
            value: [PlatterContent(id: id) { AnyView(content()) }]
        )
    }
}
