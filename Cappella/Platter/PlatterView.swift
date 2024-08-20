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
                    .safeAreaPadding(.top, headerDimension)
                    .safeAreaPadding(.bottom, footerDimension)
                    .headerBlur(with: platterGeometry)
                    .mask(makeContentMask())
                makeHeaderView()
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

        .onPreferenceChange(PlatterHeaderContentPreferenceKey.self) { value in
            headerContent = value
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
        .pin(.vertical)
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
        .pin(.vertical)
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
            .pin(.vertical)
    }

    @ViewBuilder
    private func makeHeaderView() -> some View {
        VStack {
            ForEach(headerContent) { header in
                header.content()
            }
        }
//        .background(.red.opacity(0.25))
        .offset(y: contentFrame.minY)
        .pin(.vertical)
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
}

fileprivate func lerp(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
    return (1 - t) * start + t * end
}

fileprivate extension View {
    func pin(_ axis: Axis = .vertical) -> some View {
        self.visualEffect { effect, geometry in
            guard let bounds = geometry.bounds(of: .scrollView(axis: axis)) else {
                return effect.offset()
            }

            return effect.offset(
                x: max(bounds.minX, 0.0),
                y: max(bounds.minY, 0.0)
            )
        }
    }
}

fileprivate extension View {
    func headerBlur(
        with platterGeometry: PlatterGeometry?
    ) -> some View {
        self.variableBlur(
            radius: 64.0,
            maxSampleCount: 30,
            verticalPassFirst: true
        ) { geometry, context in
            guard let platterGeometry else { return }

            let maskRect = makeMaskRect(for: geometry, platterGeometry)

            let h = platterGeometry.headerDimension
            let radius = lerp(start: 0.0, end: 10.0, t: min(maskRect.minY, h) / h)
            context.addFilter(.blur(radius: radius))

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
        _ platterGeometry: PlatterGeometry
    ) -> CGRect {
        guard let bounds = geometry.bounds(of: .scrollView(axis: .vertical)) else {
            return .zero
        }

        let rect = geometry.frame(in: .local)
        let maskRect = CGRect(
            x: rect.minX + bounds.minX,
            y: rect.minY + max(bounds.minY, 0.0),
            width: rect.width,
            height: platterGeometry.headerDimension
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
