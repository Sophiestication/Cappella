//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Variablur

struct PlatterView<Content>: View where Content: View {
    private let content: () -> Content

    @State private var headerContent = PlatterHeaderContentPreferenceKey.defaultValue
    @State private var dockedContent = PlatterDockedContentPreferenceKey.defaultValue

    @Environment(\.platterGeometry) var platterGeometry
    @Environment(\.dismissPlatter) var platterAction

    @Environment(\.pixelLength) var pixelLength
    @State var cornerRadius: CGFloat = 18.0

    @State var dragOffset: CGSize = .zero
    @State var isDragging: Bool = false

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
                        .safeAreaPadding(.top, headerDimension)
                        .safeAreaPadding(.bottom, footerDimension)
                        .blur(.header, using: platterGeometry)
//                        .blur(.docked, using: platterGeometry)
                    makeHeaderView()
                    makeDockedContentView()
                }
                .mask(makeContentMask())

                makeOverlayView()
            }
        }
        .scrollIndicators(.never)
        .scrollClipDisabled()

        .shadow(
            color: Color.black.opacity(1.0 / 4.0),
            radius: 6.0,
            x: 0.0,
            y: 5.0
        )

        .gesture(drag, name: "move-gesture")
        .offset(dragOffset)

        .onPreferenceChange(PlatterHeaderContentPreferenceKey.self) { value in
            headerContent = value
        }
        .onPreferenceChange(PlatterDockedContentPreferenceKey.self) { value in
            dockedContent = value
        }
    }

    private func makeContentMask() -> some View {
        Path(
            roundedRect: CGRect(origin: .zero, size: backgroundSize),
            cornerRadius: cornerRadius,
            style: .continuous
        )
        .fill(.black)
        .offset(y: contentFrame.minY)
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
            .pin()
    }

    @ViewBuilder
    private func makeHeaderView() -> some View {
        VStack {
            ForEach(headerContent) { header in
                header.content()
            }
        }
        .frame(height: headerDimension)
//        .background(.red.opacity(0.25))
        .offset(y: contentFrame.minY)
        .pin()
    }

    @ViewBuilder
    private func makeHeaderBackgroundView() -> some View {
        VisualEffectView(
            material: .menu,
            blendingMode: .behindWindow,
            state: .active
        )
        .mask(alignment: .top) {
            LinearGradient(
                gradient: .init(colors: [.black, .clear]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    @ViewBuilder
    private func makeDockedContentView() -> some View {
        if let dockedContent {
            dockedContent.content()
                .frame(height: footerDimension)
                .background(
                    VisualEffectView(
                        material: .menu,
                        blendingMode: .behindWindow,
                        state: .active
                    )
                    .clipShape(
                        makeDockedContentShape()
                    )
                )
                .overlay(
                    makeDockedContentShape()
                        .inset(by: -pixelLength)
                        .stroke(lineWidth: pixelLength)
                        .fill(.black.opacity(1.0 / 2.0))
                )
                .overlay(
                    makeDockedContentShape()
                        .inset(by: pixelLength)
                        .stroke(lineWidth: pixelLength)
                        .fill(.quaternary)
                )
                .padding(10.0)
                .offset(y: contentFrame.minY)
                .pin(.bottom)
        }
    }

    @ViewBuilder
    private func makeDockedContentBackgroundView() -> some View {
//        VisualEffectView(
//            material: .menu,
//            blendingMode: .behindWindow,
//            state: .active
//        )
        Color.red
        .frame(height: footerDimension)
        .mask(alignment: .top) {
            LinearGradient(
                gradient: .init(colors: [.black, .clear]),
                startPoint: .bottom,
                endPoint: .top
            )
        }
        .offset(y: contentFrame.minY)
        .pin(.bottom)
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
                dragOffset = .zero
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

fileprivate extension View {
    func blur(
        _ placement: PlatterContentPlacement = .header,
        using platterGeometry: PlatterGeometry?
    ) -> some View {
        self.variableBlur(
            radius: 64.0,
            maxSampleCount: 30,
            verticalPassFirst: true
        ) { geometry, context in
            guard let platterGeometry else { return }

            let maskRect = makeMaskRect(
                for: placement,
                geometry,
                platterGeometry
            )

            if placement == .header {
                let h = platterGeometry.headerDimension
                let radius = lerp(start: 0.0, end: 10.0, t: min(maskRect.minY, h) / h)
                context.addFilter(.blur(radius: radius))
            } else {
                let h = platterGeometry.footerDimension
                let radius = lerp(start: 12.0, end: 0.0, t: min(maskRect.minY, h) / h)
                context.addFilter(.blur(radius: radius))
            }

            let startPoint = placement == .header ?
                maskRect.origin : CGPoint(x: 0.0, y: maskRect.maxY)
            let endPoint = placement == .header ?
                CGPoint(x: 0.0, y: maskRect.maxY) : maskRect.origin

            let shading = GraphicsContext.Shading.linearGradient(
                Gradient(colors: [.white, .clear]),
                startPoint: startPoint,
                endPoint: endPoint
            )

            context.fill(
                Path(maskRect),
                with: shading
            )
        }
    }

    private func makeMaskRect(
        for placement: PlatterContentPlacement,
        _ geometry: GeometryProxy,
        _ platterGeometry: PlatterGeometry
    ) -> CGRect {
        guard let bounds = geometry.bounds(of: .scrollView(axis: .vertical)) else {
            return .zero
        }

        let rect = geometry.frame(in: .local)

        let height = placement == .header ?
            platterGeometry.headerDimension :
        platterGeometry.footerDimension + 20.0

        var maskRect = CGRect(
            x: rect.minX + bounds.minX,
            y: rect.minY + max(bounds.minY, 0.0),
            width: rect.width,
            height: height
        )

        if placement == .docked {
            maskRect = maskRect.offsetBy(
                dx: 0.0,
                dy: platterGeometry.contentFrame.minY + bounds.height - height
            )
        }

        return maskRect
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
