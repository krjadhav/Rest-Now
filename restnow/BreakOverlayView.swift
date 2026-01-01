import SwiftUI

struct BreakOverlayView: View {
    @ObservedObject var session: RestNowSession

    var body: some View {
        ZStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.85),
                        Color.black.opacity(0.65),
                        Color.black.opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.35),
                        Color.black.opacity(0.90)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 900
                )
            }
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Rest Now")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)

                Text("Take a 10 minute break. Gently look away from the screen and relax.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))

                Text(formattedTime(session.remainingSeconds))
                    .font(.system(size: 44, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)

                Button("Skip Break") {
                    session.skipBreak()
                }
            }
            .padding()
        }
    }

    private func formattedTime(_ seconds: TimeInterval) -> String {
        let total = max(Int(seconds), 0)
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
