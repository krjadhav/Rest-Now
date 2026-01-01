import AppKit
import SwiftUI
import CoreGraphics

final class BreakOverlayWindowManager {
    private let session: RestNowSession
    private var windows: [NSWindow] = []

    init(session: RestNowSession) {
        self.session = session
    }

    func show() {
        guard windows.isEmpty else {
            windows.forEach { $0.orderFrontRegardless() }
            return
        }

        let level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))

        for screen in NSScreen.screens {
            let frame = screen.frame
            let window = NSWindow(
                contentRect: frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )

            window.setFrame(frame, display: true)

            window.isReleasedWhenClosed = false
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.level = level
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

            let hostingView = NSHostingView(rootView: BreakOverlayView(session: session))
            hostingView.frame = NSRect(origin: .zero, size: frame.size)
            hostingView.autoresizingMask = [.width, .height]
            window.contentView = hostingView

            windows.append(window)
        }

        NSApp.activate(ignoringOtherApps: true)

        for (idx, window) in windows.enumerated() {
            if idx == 0 {
                window.makeKeyAndOrderFront(nil)
            } else {
                window.orderFrontRegardless()
            }
        }
    }

    func hide() {
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
    }
}
