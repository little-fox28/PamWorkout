import SwiftUI
import Core

// MARK: - IntervalTimerView

/// NFN3: Large touch targets for sweaty-hand gym use.
/// Uses semantic dark theme colors from Core/DesignSystem/Theme.swift.
public struct IntervalTimerView: View {

    @StateObject private var vm = IntervalTimerViewModel()
    @Environment(\.scenePhase) private var scenePhase

    public init() {}

    public var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                Spacer()
                progressRingSection
                Spacer()
                controlsSection
                Spacer()
                configSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            // Completion overlay
            if case .completed = vm.phase {
                completionOverlay
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:  vm.handleBackground()
            case .active:       vm.handleForeground()
            default:            break
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("Interval Timer")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(Theme.Colors.textPrimary)

            if case .idle = vm.phase {} else {
                Text("Set \(vm.currentSet) of \(vm.config.sets)")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(phaseColor.opacity(0.8))
                    .animation(.easeInOut, value: vm.currentSet)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Progress Ring

    private var progressRingSection: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Theme.Colors.surface, lineWidth: 18)
                .frame(width: 280, height: 280)

            // Progress arc — color changes by phase (FN2)
            Circle()
                .trim(from: 0, to: vm.progress)
                .stroke(
                    phaseColor,
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: vm.progress)

            // Center content
            VStack(spacing: 8) {
                Text(formattedTime)
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())

                phaseLabel
            }
        }
    }

    private var phaseLabel: some View {
        Group {
            switch vm.phase {
            case .idle:
                Text("Ready").foregroundColor(Theme.Colors.textSecondary)
            case .working:
                Text("PLANK / WORK")
                    .foregroundColor(phaseColor)
                    .fontWeight(.heavy)
            case .resting:
                Text("REST")
                    .foregroundColor(phaseColor)
                    .fontWeight(.heavy)
            case .paused:
                Text("PAUSED")
                    .foregroundColor(Theme.Colors.textSecondary)
            case .completed:
                Text("DONE!")
                    .foregroundColor(Theme.Colors.primaryAccent)
            }
        }
        .font(.system(.title3, design: .rounded))
    }

    // MARK: - Controls (NFN3: massive hit targets)

    private var controlsSection: some View {
        VStack(spacing: 16) {
            // Main Start/Pause button
            Button(action: mainButtonAction) {
                Text(mainButtonLabel)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)  // NFN3: large touch target
                    .background(mainButtonColor)
                    .foregroundColor(Theme.Colors.background)
                    .cornerRadius(20)
            }
            .disabled(isMainButtonDisabled)

            HStack(spacing: 12) {
                // Skip Rest button
                if case .resting = vm.phase {
                    Button(action: { vm.skipRest() }) {
                        Label("Skip Rest", systemImage: "forward.fill")
                            .font(.system(.callout, design: .rounded, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Theme.Colors.surface)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .cornerRadius(16)
                    }
                }

                // Reset button
                if vm.phase != .idle {
                    Button(action: { vm.reset() }) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.system(.callout, design: .rounded, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Theme.Colors.surface)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .cornerRadius(16)
                    }
                }
            }
        }
    }

    // MARK: - Config Section (FN1)

    @ViewBuilder
    private var configSection: some View {
        if case .idle = vm.phase {
            VStack(spacing: 16) {
                Divider().background(Theme.Colors.surface)

                HStack(spacing: 20) {
                    StepperCard(
                        label: "Sets",
                        value: vm.config.sets,
                        range: 1...20,
                        onIncrement: { vm.config.sets += 1 },
                        onDecrement: { if vm.config.sets > 1 { vm.config.sets -= 1 } }
                    )

                    StepperCard(
                        label: "Work (s)",
                        value: Int(vm.config.workDuration),
                        range: 5...600,
                        onIncrement: { vm.config.workDuration += 5 },
                        onDecrement: { if vm.config.workDuration > 5 { vm.config.workDuration -= 5 } }
                    )

                    StepperCard(
                        label: "Rest (s)",
                        value: Int(vm.config.restDuration),
                        range: 5...300,
                        onIncrement: { vm.config.restDuration += 5 },
                        onDecrement: { if vm.config.restDuration > 5 { vm.config.restDuration -= 5 } }
                    )
                }
            }
        }
    }

    // MARK: - Completion Overlay (FN5)

    private var completionOverlay: some View {
        ZStack {
            Theme.Colors.background.opacity(0.92).ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.Colors.primaryAccent)

                Text("Session Complete!")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundColor(Theme.Colors.textPrimary)

                VStack(spacing: 8) {
                    Text("Total Work Time")
                        .font(.headline)
                        .foregroundColor(Theme.Colors.textSecondary)
                    Text(formatDuration(vm.completedWorkTime))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.Colors.primaryAccent)
                }
                .padding()
                .background(Theme.Colors.surface)
                .cornerRadius(16)

                Button(action: { vm.reset() }) {
                    Text("Done")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Theme.Colors.primaryAccent)
                        .foregroundColor(Theme.Colors.background)
                        .cornerRadius(18)
                }
            }
            .padding(32)
        }
        .transition(.opacity.animation(.easeInOut))
    }

    // MARK: - Helpers

    private var phaseColor: Color {
        switch vm.phase {
        case .working:         return Color(red: 1, green: 0.35, blue: 0.15) // Vibrant Orange-Red
        case .resting:         return Color(red: 0.2, green: 0.85, blue: 0.4) // Vibrant Green
        case .paused:          return Theme.Colors.textSecondary
        default:               return Theme.Colors.primaryAccent
        }
    }

    private var mainButtonLabel: String {
        switch vm.phase {
        case .idle:             return "Start"
        case .working, .resting: return "Pause"
        case .paused:           return "Resume"
        case .completed:        return "Done"
        }
    }

    private var mainButtonColor: Color {
        switch vm.phase {
        case .idle, .paused:    return Theme.Colors.primaryAccent
        case .working, .resting: return Color(red: 0.95, green: 0.3, blue: 0.25)
        case .completed:        return Theme.Colors.primaryAccent
        }
    }

    private var isMainButtonDisabled: Bool {
        if case .completed = vm.phase { return true }
        return false
    }

    private func mainButtonAction() {
        switch vm.phase {
        case .idle:                     vm.start()
        case .working, .resting, .paused: vm.pauseOrResume()
        default:                        break
        }
    }

    private var formattedTime: String {
        let total = Int(ceil(vm.timeRemaining))
        let m = total / 60
        let s = total % 60
        return m > 0 ? String(format: "%d:%02d", m, s) : String(format: "0:%02d", s)
    }

    private func formatDuration(_ t: TimeInterval) -> String {
        let total = Int(t)
        let m = total / 60
        let s = total % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }
}

// MARK: - StepperCard Component (FN1)

private struct StepperCard: View {
    let label: String
    let value: Int
    let range: ClosedRange<Int>
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(Theme.Colors.textSecondary)

            Text("\(value)")
                .font(.system(.title2, design: .monospaced, weight: .bold))
                .foregroundColor(Theme.Colors.textPrimary)

            HStack(spacing: 8) {
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                        .frame(width: 32, height: 32)
                        .background(Theme.Colors.surface)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .cornerRadius(8)
                }
                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .frame(width: 32, height: 32)
                        .background(Theme.Colors.surface)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(Theme.Colors.surface.opacity(0.6))
        .cornerRadius(12)
    }
}
