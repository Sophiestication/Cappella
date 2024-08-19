//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Variablur

struct PlatterView<Content>: View where Content: View {
    private let content: () -> Content

    @State private var headerContent = PlatterHeaderContentPreferenceKey.defaultValue

    @Environment(\.platterGeometry) var platterGeometry
    @Environment(\.dismissPlatter) var platterAction

    @Environment(\.pixelLength) var pixelLength
    @State var overlayLineWidth: CGFloat = 1.0
    @State var cornerRadius: CGFloat = 18.0

    init(
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.content = content
    }

    var body: some View {
        ScrollView(.vertical) {
            ZStack(alignment: .top) {
                makeBackgroundView()
                content()
                    .padding(.top, headerDimension)
                    .padding(.bottom, footerDimension)
                    .mask(contentMask)
                makeHeaderView()
                makeOverlayView()
            }
        }
        .frame(
            width: contentFrame.width,
            height: contentFrame.maxY
        )

        .shadow(
            color: Color.black.opacity(1.0 / 4.0),
            radius: 6.0,
            x: 0.0,
            y: 5.0
        )

        .onScrollGeometryChange(for: CGPoint.self, of: { scrollGeometry in
            scrollGeometry.contentOffset
        }, action: { oldValue, newValue in
            if oldValue == newValue {
                return
            }

            if let platterGeometry {
                platterGeometry.contentOffset = newValue
            }
        })
        .scrollIndicators(.never)
        .scrollClipDisabled()

        .onPreferenceChange(PlatterHeaderContentPreferenceKey.self) { value in
            headerContent = value
        }
    }

    private var contentMask: Path {
        guard let platterGeometry else {
            return Path()
        }

        let contentRect = platterGeometry.contentFrame

        var rect = CGRect(
            x: 0.0,
            y: contentRect.minY,
            width: contentRect.width,
            height: contentRect.height
        )

        let contentOffset = platterGeometry.contentOffset

        rect = rect.offsetBy(
            dx: contentOffset.x,
            dy: max(contentOffset.y, 0.0)
        )

        return Path(
            roundedRect: rect,
            cornerRadius: cornerRadius,
            style: .continuous
        )
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
        .offset(backgroundOffset)
    }

    private var backgroundSize: CGSize {
        guard let platterGeometry else {
            return .zero
        }

        let containerSize = platterGeometry.contentFrame

        let backgroundSize = CGSizeMake(
            containerSize.width,
            containerSize.height
        )
        return backgroundSize
    }

    private var backgroundOffset: CGSize {
        guard let platterGeometry else {
            return .zero
        }

        let contentOffset = platterGeometry.contentOffset

        return CGSize(
            width: contentOffset.x,
            height: max(contentOffset.y, 0.0) + platterGeometry.contentFrame.minY
        )
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
            .offset(backgroundOffset)
    }

    @ViewBuilder
    private func makeHeaderView() -> some View {
        VStack {
            ForEach(headerContent) { header in
                header.content()
            }
        }
        .padding(.top, headerTopPadding)
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

    private var headerTopPadding: CGFloat {
        let contentFrame = contentFrame
        return contentFrame.minY
    }

    private var scrollViewBottomPadding: CGFloat {
        guard let platterGeometry else {
            return 0.0
        }

        let containerFrame = platterGeometry.containerFrame
        let contentFrame = platterGeometry.contentFrame

        return containerFrame.maxY - contentFrame.maxY
    }
}

extension View {
    func headerBlur(
        with platterGeometry: PlatterGeometry?,
        _ scrollGeometry: ScrollGeometry? = nil
    ) -> some View {
        self.variableBlur(
            radius: 64.0,
            maxSampleCount: 32,
            verticalPassFirst: true
        ) { geometry, context in
            let maskRect = makeMaskRect(for: geometry, platterGeometry, scrollGeometry)

//            context.addFilter(.blur(radius: 40))

            let shading = GraphicsContext.Shading.linearGradient(
                Gradient(colors: [.white, .clear]),
                startPoint: maskRect.origin,
                endPoint: CGPoint(x: 0.0, y: maskRect.maxY)
            )

            context.fill(
                Path(maskRect),
                with: shading
            )
        }
    }

    private func makeMaskRect(
        for geometry: GeometryProxy,
        _ platterGeometry: PlatterGeometry?,
        _ scrollGeometry: ScrollGeometry?
    ) -> CGRect {
        guard let scrollGeometry,
              let platterGeometry else {
            return .zero
        }

        let rect = geometry.frame(in: .local)

        let maskOrigin = CGPoint(
            x: rect.minX + scrollGeometry.contentOffset.x,
            y: rect.minY + scrollGeometry.contentOffset.y
        )

        let maskSize = CGSize(
            width: rect.width,
            height: platterGeometry.headerDimension
        )

        let maskRect = CGRect(
            origin: maskOrigin,
            size: maskSize
        )

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

struct PlatterContentPlacement {
    fileprivate let preferenceKey: PlatterHeaderContentPreferenceKey.Type

    static let header = PlatterContentPlacement(
        preferenceKey: PlatterHeaderContentPreferenceKey.self
    )
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
