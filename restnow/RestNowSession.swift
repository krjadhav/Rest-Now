import Foundation
import AppKit
import Combine

final class RestNowSession: ObservableObject {
    enum Phase {
        case work
        case rest
    }

    private let workDuration: TimeInterval
    private let breakDuration: TimeInterval

    @Published private(set) var phase: Phase
    @Published private(set) var remainingSeconds: TimeInterval

    private var timer: Timer?

    init(
        workDuration: TimeInterval = 2 * 5,
        breakDuration: TimeInterval = 1 * 5
    ) {
        self.workDuration = workDuration
        self.breakDuration = breakDuration
        self.phase = .work
        self.remainingSeconds = workDuration
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    func resetCycle() {
        phase = .work
        remainingSeconds = workDuration
    }

    func startBreakNow() {
        phase = .rest
        remainingSeconds = breakDuration
        playBell()
    }

    func skipBreak() {
        phase = .work
        remainingSeconds = workDuration
    }

    var menuBarTitle: String {
        switch phase {
        case .work:
            return formattedTime(remainingSeconds)
        case .rest:
            return "Break " + formattedTime(remainingSeconds)
        }
    }

    private func startTimer() {
        timer?.invalidate()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            switchPhase()
            return
        }
        remainingSeconds -= 1
    }

    private func switchPhase() {
        switch phase {
        case .work:
            startBreakNow()
        case .rest:
            skipBreak()
        }
    }

    private func playBell() {
        NSSound(named: NSSound.Name("Submarine"))?.play()
    }

    private func formattedTime(_ seconds: TimeInterval) -> String {
        let total = max(Int(seconds), 0)
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
