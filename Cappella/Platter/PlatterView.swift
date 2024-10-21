//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterView<Content>: View where Content: View {
    private let content: () -> Content

    @State private var headerContent = PlatterHeaderContentPreferenceKey.defaultValue
    @State private var dockedContent = PlatterDockedContentPreferenceKey.defaultValue

    @Environment(\.platterGeometry) var platterGeometry

    @Environment(\.pixelLength) var pixelLength
    @State var cornerRadius: CGFloat = 18.0

    @State var dragOffset: CGSize = .zero
    @State var isDragging: Bool = false

    @State var headerBackgroundShown: Bool = false

    init(
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.content = content
    }

    var body: some View {
        ScrollView(.vertical) {
            ZStack(alignment: .top) {
                makeBackgroundView()

                Group {
                    content()
                        .buttonStyle(.platter)
                        .containerRelativeFrame(.horizontal)
                    makeHeaderView()
                    makeDockedContentView()
                }
                .mask(makeContentMask())

                makeOverlayView()
            }
            .coordinateSpace(name: "content")
        }

        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.y > -headerDimension
        } action: { wasBeyondZero, isBeyondZero in
            withAnimation(.snappy) {
                self.headerBackgroundShown = isBeyondZero
            }
        }

        .scrollIndicators(.never)
        .scrollClipDisabled()

        .fontWeight(.medium)
        .fontDesign(.rounded)

        .shadow(
            color: Color.black.opacity(1.0 / 4.0),
            radius: 12.0,
            x: 0.0,
            y: 5.0
        )

        .smoothShadow(
            color: .black.opacity(0.08),
            layers: 5,
            curve: .easeInOut,
            radius: 28.0,
            x: 0.0,
            y: 32.0
        )

        .gesture(drag, name: "move-gesture")
        .offset(dragOffset)

        .onPreferenceChange(PlatterHeaderContentPreferenceKey.self) { value in
            headerContent = value
        }
        .onPreferenceChange(PlatterDockedContentPreferenceKey.self) { value in
            dockedContent = value
        }

        .contentMargins(.top, headerDimension)
        .contentMargins(.bottom, footerDimension)

        .allowsWindowActivationEvents()
    }

    private func makeContentMask() -> some View {
        Path(
            roundedRect: CGRect(origin: .zero, size: backgroundSize),
            cornerRadius: cornerRadius,
            style: .continuous
        )
        .fill(.black)
        .offset(y: contentFrame.minY)
        .offset(y: -headerDimension)
        .pin()
    }

    private func makePlatterShape() -> RoundedRectangle {
        RoundedRectangle(
            cornerRadius: cornerRadius,
            style: .continuous
        )
    }

    @ViewBuilder
    private func makeBackgroundView() -> some View {
        VisualEffectView(
            material: .menu,
            blendingMode: .behindWindow,
            state: .active
        )
        .clipShape(makePlatterShape())
        .overlay(
            makePlatterShape()
                .inset(by: -pixelLength)
                .stroke(lineWidth: pixelLength)
                .fill(.black.opacity(1.0 / 2.0))
        )
        .frame(
            width: backgroundSize.width,
            height: backgroundSize.height
        )
        .offset(y: contentFrame.minY)
        .offset(y: -headerDimension)
        .pin()
    }

    private var backgroundSize: CGSize {
        guard let platterGeometry else {
            return .zero
        }

        return platterGeometry.contentFrame.size
    }

    @ViewBuilder
    private func makeOverlayView() -> some View {
        makePlatterShape()
            .inset(by: pixelLength)
            .stroke(lineWidth: pixelLength)
            .fill(.white.opacity(1.0 / 3.0))
            .frame(
                width: backgroundSize.width,
                height: backgroundSize.height
            )
            .offset(y: contentFrame.minY)
            .offset(y: -headerDimension)
            .pin()
    }

    @ViewBuilder
    private func makeHeaderView() -> some View {
        VStack {
            ForEach(headerContent) { header in
                header.content()
                    .offset(y: contentFrame.minY * 0.50)
            }
        }
        .frame(height: headerDimension - contentFrame.minY)

        .background {
            ContainerRelativeShape()
                .fill(Material.ultraThin)
                .opacity(headerBackgroundShown ? 1.0 : 0.0)
        }
        .overlay(
            ContainerRelativeShape()
                .fill(.white.opacity(1.0 / 9.0))
                .blendMode(.screen)
                .frame(height: pixelLength)
                .padding(.horizontal, 1.0)
                .opacity(headerBackgroundShown ? 1.0 : 0.0),
            alignment: .bottom
        )

        .offset(y: contentFrame.minY)
        .offset(y: -headerDimension)

        .pin()
    }

    @ViewBuilder
    private func makeDockedContentView() -> some View {
        if let dockedContent {
            dockedContent
                .content()
                .background(Material.ultraThin)
                .overlay(
                    ContainerRelativeShape()
                        .fill(.white.opacity(1.0 / 9.0))
                        .blendMode(.screen)
                        .frame(height: pixelLength)
                        .padding(.horizontal, 1.0),
                    alignment: .top
                )

                .offset(y: contentFrame.minY)
                .offset(y: footerDimension)

                .pin(.bottom)
        }
    }

    private func makeDockedContentShape() -> RoundedRectangle {
        RoundedRectangle(
            cornerRadius: 14.0,
            style: .continuous
        )
    }

    private var contentFrame: CGRect {
        guard let platterGeometry else {
            return .zero
        }

        return platterGeometry.contentFrame
    }

    private var headerDimension: CGFloat {
        guard let platterGeometry else {
            return 0.0
        }

        return platterGeometry.headerDimension
    }

    private var footerDimension: CGFloat {
        guard let platterGeometry else {
            return 0.0
        }

        return platterGeometry.footerDimension
    }

    private var drag: some Gesture {
        DragGesture(
            minimumDistance: 0.0,
            coordinateSpace: .global
        )
        .onChanged { value in
            let translation = value.translation
            let itemSize = CGSize(
                width: backgroundSize.width * (1.0 / 3.0),
                height: backgroundSize.height * (1.0 / 3.0)
            )

            let rangeFactor: CGFloat = 0.0
            let range = -itemSize.width * rangeFactor...itemSize.width * rangeFactor
            let interval = itemSize
            let c = 0.30

            let dragOffset = CGSize(
                width: rubberband(
                    value: translation.width,
                    range: range,
                    interval: interval.width,
                    c: c
                ),
                height: rubberband(
                    value: translation.height,
                    range: range,
                    interval: interval.height,
                    c: c
                )
            )
            self.dragOffset = dragOffset
        }
        .onEnded { _ in
            withAnimation(.smooth) {
                self.dragOffset = .zero
            }
        }
    }
}

fileprivate func lerp(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
    return (1 - t) * start + t * end
}

fileprivate extension View {
    func pin(_ edge: VerticalEdge = .top) -> some View {
        self.visualEffect { effect, geometry in
            guard let bounds = geometry.bounds(of: .scrollView(axis: .vertical)) else {
                return effect.offset()
            }

            switch edge {
            case .top:
                return effect.offset(
                    x: max(bounds.minX, 0.0),
                    y: max(bounds.minY, 0.0)
                )

            case .bottom:
                return effect.offset(
                    x: max(bounds.minX, 0.0),
                    y: max(bounds.minY, 0.0) + (bounds.height - geometry.size.height)
                )
            }
        }
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

fileprivate struct PlatterDockedContentPreferenceKey: PreferenceKey {
    typealias Value = PlatterContent?

    static let defaultValue: Value = nil
    static func reduce(value: inout Value, nextValue: () -> Value) {
        if let next = nextValue() {
            value = next
        }
    }
}

enum PlatterContentPlacement {
    case header
    case docked
}

extension View {
    @ViewBuilder
    func platterContent<Content: View>(
        id: String,
        placement: PlatterContentPlacement,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        switch placement {
            case .header:
                self.preference(
                    key: PlatterHeaderContentPreferenceKey.self,
                    value: [PlatterContent(id: id) { AnyView(content()) }]
                )

            case .docked:
                self.preference(
                    key: PlatterDockedContentPreferenceKey.self,
                    value: PlatterContent(id: id) { AnyView(content()) }
                )
        }
    }
}
