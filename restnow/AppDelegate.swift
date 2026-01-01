import AppKit
import Combine
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private enum DefaultsKey {
        static let workDurationSeconds = "restnow.workDurationSeconds"
        static let restDurationSeconds = "restnow.restDurationSeconds"
    }

    private var session: RestNowSession?
    private var overlayManager: BreakOverlayWindowManager?

    private var statusItem: NSStatusItem?

    private var startBreakItem: NSMenuItem?
    private var skipBreakItem: NSMenuItem?
    private var pauseCycleItem: NSMenuItem?
    private var resetItem: NSMenuItem?

    private var cancellables = Set<AnyCancellable>()

    private var onboardingWindow: NSWindow?
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        if let work = UserDefaults.standard.object(forKey: DefaultsKey.workDurationSeconds) as? Double,
           let rest = UserDefaults.standard.object(forKey: DefaultsKey.restDurationSeconds) as? Double {
            startSession(workDuration: work, restDuration: rest)
        } else {
            showOnboarding()
        }
    }

    @objc private func startBreakNow() {
        session?.startBreakNow()
    }

    @objc private func skipBreak() {
        session?.skipBreak()
    }

    @objc private func resetCycle() {
        session?.resetCycle()
    }

    @objc private func togglePauseCycle() {
        session?.togglePause()
    }

    @objc private func openSettings() {
        showSettings()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    private func startSession(workDuration: TimeInterval, restDuration: TimeInterval) {
        cancellables.removeAll()

        overlayManager?.hide()
        overlayManager = nil

        let session = RestNowSession(workDuration: workDuration, breakDuration: restDuration)
        self.session = session

        let overlayManager = BreakOverlayWindowManager(session: session)
        self.overlayManager = overlayManager

        let item: NSStatusItem
        if let existing = statusItem {
            item = existing
        } else {
            item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            statusItem = item
        }

        if let button = item.button {
            let symbolConfig = NSImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            let image = (
                NSImage(systemSymbolName: "eye.half.closed.fill", accessibilityDescription: "Rest Now") ??
                NSImage(systemSymbolName: "eye.fill", accessibilityDescription: "Rest Now") ??
                NSImage(systemSymbolName: "eye", accessibilityDescription: "Rest Now")
            )?
                .withSymbolConfiguration(symbolConfig)
            image?.isTemplate = true
            button.image = image
            button.imagePosition = .imageLeft
            button.imageScaling = .scaleProportionallyDown
        }

        item.button?.title = session.menuBarTitle

        let menu = NSMenu()

        let pauseCycle = NSMenuItem(title: "Pause Cycle", action: #selector(togglePauseCycle), keyEquivalent: "p")
        pauseCycle.target = self
        menu.addItem(pauseCycle)
        self.pauseCycleItem = pauseCycle

        let reset = NSMenuItem(title: "Reset Cycle", action: #selector(resetCycle), keyEquivalent: "r")
        reset.target = self
        menu.addItem(reset)
        self.resetItem = reset

        menu.addItem(.separator())

        let startBreak = NSMenuItem(title: "Start Break Now", action: #selector(startBreakNow), keyEquivalent: "b")
        startBreak.target = self
        menu.addItem(startBreak)
        self.startBreakItem = startBreak

        let skipBreak = NSMenuItem(title: "Skip Break", action: #selector(skipBreak), keyEquivalent: "s")
        skipBreak.target = self
        menu.addItem(skipBreak)
        self.skipBreakItem = skipBreak

        menu.addItem(.separator())

        let settings = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)

        let quit = NSMenuItem(title: "Quit Rest Now", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        item.menu = menu

        Publishers.CombineLatest3(session.$phase, session.$remainingSeconds, session.$isPaused)
            .receive(on: RunLoop.main)
            .sink { [weak self] phase, _, isPaused in
                guard let self else { return }
                self.statusItem?.button?.title = session.menuBarTitle
                self.pauseCycleItem?.title = isPaused ? "Resume Cycle" : "Pause Cycle"

                switch phase {
                case .work:
                    self.skipBreakItem?.isEnabled = false
                    self.startBreakItem?.isEnabled = true
                    overlayManager.hide()
                case .rest:
                    self.skipBreakItem?.isEnabled = true
                    self.startBreakItem?.isEnabled = false
                    overlayManager.show()
                }
            }
            .store(in: &cancellables)

        skipBreakItem?.isEnabled = false
    }

    private func showOnboarding() {
        let hostingView = NSHostingView(
            rootView: OnboardingView(
                title: "RestNow",
                subtitle: "Choose your work and rest durations.",
                primaryButtonTitle: "Start",
                initialWorkSeconds: 30,
                initialRestSeconds: 10
            ) { [weak self] workDuration, restDuration in
                guard let self else { return }

                UserDefaults.standard.set(workDuration, forKey: DefaultsKey.workDurationSeconds)
                UserDefaults.standard.set(restDuration, forKey: DefaultsKey.restDurationSeconds)

                self.onboardingWindow?.close()
                self.onboardingWindow = nil

                self.startSession(workDuration: workDuration, restDuration: restDuration)
            }
        )

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 240),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "Rest Now"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)
        window.isMovableByWindowBackground = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.isReleasedWhenClosed = false
        window.contentView = hostingView
        window.center()

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)

        onboardingWindow = window
    }

    private func showSettings() {
        if let settingsWindow {
            NSApp.activate(ignoringOtherApps: true)
            settingsWindow.makeKeyAndOrderFront(nil)
            return
        }

        let workSecondsRaw = UserDefaults.standard.double(forKey: DefaultsKey.workDurationSeconds)
        let restSecondsRaw = UserDefaults.standard.double(forKey: DefaultsKey.restDurationSeconds)

        let allowed: Set<Int> = [5, 10, 30, 60]

        let initialWork = allowed.contains(Int(workSecondsRaw)) ? Int(workSecondsRaw) : 30
        let initialRest = allowed.contains(Int(restSecondsRaw)) ? Int(restSecondsRaw) : 10

        let hostingView = NSHostingView(
            rootView: OnboardingView(
                title: "Rest Now",
                subtitle: "Update your work and rest durations.",
                primaryButtonTitle: "Save",
                initialWorkSeconds: initialWork,
                initialRestSeconds: initialRest,
                showsProjectLink: true
            ) { [weak self] workDuration, restDuration in
                guard let self else { return }

                UserDefaults.standard.set(workDuration, forKey: DefaultsKey.workDurationSeconds)
                UserDefaults.standard.set(restDuration, forKey: DefaultsKey.restDurationSeconds)

                self.settingsWindow?.close()
                self.settingsWindow = nil

                self.startSession(workDuration: workDuration, restDuration: restDuration)
            }
        )

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 240),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "Settings"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)
        window.isMovableByWindowBackground = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.isReleasedWhenClosed = false
        window.contentView = hostingView
        window.center()

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)

        settingsWindow = window
    }
}
