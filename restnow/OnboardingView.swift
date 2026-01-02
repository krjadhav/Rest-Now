import SwiftUI

struct OnboardingView: View {
    private let options: [Int] = [1, 5, 10, 20, 30, 60]

    private let title: String
    private let subtitle: String
    private let primaryButtonTitle: String
    private let showsProjectLink: Bool

    @State private var selectedWorkMinutes: Int
    @State private var selectedRestMinutes: Int

    let onCommit: (_ workDuration: TimeInterval, _ restDuration: TimeInterval) -> Void

    init(
        title: String = "Rest Now",
        subtitle: String = "Choose your work and rest durations.",
        primaryButtonTitle: String = "Start",
        initialWorkMinutes: Int = 30,
        initialRestMinutes: Int = 10,
        showsProjectLink: Bool = false,
        onCommit: @escaping (_ workDuration: TimeInterval, _ restDuration: TimeInterval) -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.primaryButtonTitle = primaryButtonTitle
        self.showsProjectLink = showsProjectLink
        self.onCommit = onCommit
        _selectedWorkMinutes = State(initialValue: initialWorkMinutes)
        _selectedRestMinutes = State(initialValue: initialRestMinutes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title.weight(.bold))

            Text(subtitle)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                Picker("Work Duration", selection: $selectedWorkMinutes) {
                    ForEach(options, id: \.self) { value in
                        Text("\(value)m").tag(value)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 10) {
                Picker("Rest Duration", selection: $selectedRestMinutes) {
                    ForEach(options, id: \.self) { value in
                        Text("\(value)m").tag(value)
                    }
                }
                .pickerStyle(.segmented)
            }

            if showsProjectLink {
                HStack(spacing: 0) {
                    Text("Rest Now is made by Kausthub Jadhav. Feel free to contribute ")

                    if let url = URL(string: "https://github.com/krjadhav/Rest-Now") {
                        Link("here.", destination: url)
                            .foregroundStyle(.blue)
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()

                Button(primaryButtonTitle) {
                    onCommit(TimeInterval(selectedWorkMinutes * 60), TimeInterval(selectedRestMinutes * 60))
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .padding(.top, 8)
        .frame(width: 460)
        .background(.regularMaterial.opacity(0.99))
    }
}
