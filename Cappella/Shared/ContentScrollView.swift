//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import AppKit

struct ContentScrollView<V1, V2, V3>: View where V1: View, V2: View, V3: View {
    private let content: () -> V1
    private let header: () -> V2
    private let footer: () -> V3

    @State private var contentOffset = CGPoint(x: 0.0, y: 0.0)

    init(
        @ViewBuilder _ content: @escaping () -> V1,
        @ViewBuilder header: @escaping () -> V2 = { EmptyView() },
        @ViewBuilder footer: @escaping () -> V3 = { EmptyView() }
    ) {
        self.content = content
        self.header = header
        self.footer = footer
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Text("\(contentOffset)")

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0.0, pinnedViews: [.sectionHeaders, .sectionFooters]) {
                    makeHeaderView()

                    content()
                        .background(
                            GeometryReader { offsetObserverGeometry in
                                Color.clear
                                    .preference(
                                        key: ScrollViewOffsetPreferenceKey.self,
                                        value: frame(for: offsetObserverGeometry).origin
                                    )
                            }
                        )

                    makeFooterView()
                }
            }
            .coordinateSpace(name: "content-scrollview")
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { newContentOffset in
                contentOffset = newContentOffset
            }
        }
    }

    @ViewBuilder
    private func makeHeaderView() -> some View {
        header()
//            .offset(x: 0.0, y: contentOffset.y)
    }

    @ViewBuilder
    private func makeFooterView() -> some View {
        footer()
            .frame(height: 44.0)
//            .offset(x: 0.0, y: -contentOffset.y)
    }

    private func frame(for geometry: GeometryProxy) -> CGRect {
        let frame = geometry.frame(in: .named("content-scrollview"))
        return frame
    }
}

fileprivate struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGPoint

    static let defaultValue: Value = CGPoint(x: 0.0, y: 0.0)
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

fileprivate struct CustomScrollView<Content: View>: NSViewRepresentable {
    var content: Content
    @Binding var scrollOffset: CGPoint

    init(scrollOffset: Binding<CGPoint>, @ViewBuilder content: () -> Content) {
        self._scrollOffset = scrollOffset
        self.content = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()

        let hostingView = NSHostingView(rootView: content)
        hostingView.autoresizingMask = [ .width, .height ]

        scrollView.documentView = hostingView
        scrollView.drawsBackground = false

        context.coordinator.registerScrollObserver(for: scrollView)

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let currentOffset = nsView.contentView.bounds.origin

        if currentOffset != scrollOffset {
            scrollOffset = currentOffset
        }
    }

    class Coordinator: NSObject {
        var parent: CustomScrollView
        private var observation: NSKeyValueObservation?

        init(_ parent: CustomScrollView) {
            self.parent = parent
        }

        @MainActor
        func registerScrollObserver(for scrollView: NSScrollView) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(scrollViewDidScroll(_:)),
                name: NSView.boundsDidChangeNotification,
                object: scrollView.contentView
            )
        }

        @MainActor
        @objc func scrollViewDidScroll(_ notification: Notification) {
            if let contentView = notification.object as? NSClipView {
                let newOffset = contentView.documentVisibleRect.origin

                if newOffset != parent.scrollOffset {
                    parent.scrollOffset = newOffset
                }
            }
        }

        deinit {
            NotificationCenter.default.removeObserver(
                self,
                name: NSView.boundsDidChangeNotification,
                object: nil
            )
        }
    }
}

#Preview {
    ContentScrollView {
        Color.red
            .frame(height: 1000.0)
    } header: {
        Color.orange
    } footer: {
        Color.cyan
    }
}
