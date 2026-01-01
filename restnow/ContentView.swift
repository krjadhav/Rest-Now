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

    private var overlayAnimation: Animation {
        .easeInOut(duration: 0.45)
    }

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
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    VStack(spacing: 20) {
                        Text("Rest Now")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.white)

                        Text("Take a break. Stand up. Strech.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.9))

                        Text(formattedTime(remainingSeconds))
                            .font(.system(size: 44, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)

                        Button {
                            resetToWork()
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: "chevron.right.2")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Skip Break")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.35))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
                .zIndex(1)
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
        withAnimation(overlayAnimation) {
            switch phase {
            case .work:
                phase = .rest
                remainingSeconds = breakDuration
            case .rest:
                phase = .work
                remainingSeconds = workDuration
            }
        }
        playBell()
    }

    private func resetToWork() {
        withAnimation(overlayAnimation) {
            phase = .work
            remainingSeconds = workDuration
        }
    }

    private func togglePhaseManually() {
        switchPhase()
    }

    private func playBell() {
        NSSound(named: NSSound.Name("Funk"))?.play()
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
