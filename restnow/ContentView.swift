//
//  ContentView.swift
//  restnow
//
//  Created by Kausthub Jadhav on 01/01/26.
//

import SwiftUI
import AppKit
import Combine

struct ContentView: View {
    private let workDuration: TimeInterval = 2 * 5
    private let breakDuration: TimeInterval = 1 * 5

    private enum Phase {
        case work
        case rest
    }

    @State private var phase: Phase = .work
    @State private var remainingSeconds: TimeInterval = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text(phase == .work ? "Next break in" : "Break time remaining")
                    .font(.title2)

                Text(formattedTime(remainingSeconds))
                    .font(.system(size: 48, weight: .semibold, design: .monospaced))

                Text(phase == .work ? "Keep working until your next gentle reminder." : "Look away from the screen and rest your eyes.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button("Reset Cycle") {
                        resetToWork()
                    }

                    Button(phase == .work ? "Start Break Now" : "Skip Break") {
                        togglePhaseManually()
                    }
                }
            }
            .padding()

            if phase == .rest {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Rest Now")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)

                    Text("Take a 10 minute break. Gently look away from the screen and relax.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))

                    Text(formattedTime(remainingSeconds))
                        .font(.system(size: 44, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)

                    Button("Skip Break") {
                        resetToWork()
                    }
                }
                .padding()
            }
        }
        .onAppear {
            if remainingSeconds <= 0 {
                remainingSeconds = workDuration
            }
        }
        .onReceive(timer) { _ in
            tick()
        }
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
            phase = .rest
            remainingSeconds = breakDuration
            playBell()
        case .rest:
            phase = .work
            remainingSeconds = workDuration
            playBell()
        }
    }

    private func resetToWork() {
        phase = .work
        remainingSeconds = workDuration
    }

    private func togglePhaseManually() {
        switchPhase()
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

#Preview {
    ContentView()
}
