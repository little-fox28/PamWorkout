import Foundation
import AVFoundation
@preconcurrency import ActivityKit
import UIKit

// MARK: - Timer Phase

public enum TimerPhase: Equatable, Sendable {
    case idle
    case working
    case resting
    case paused(resumePhase: PausedPhase)
    case completed
}

public enum PausedPhase: Sendable {
    case work, rest
}

// MARK: - Timer Configuration

public struct TimerConfiguration: Equatable, Sendable {
    public var sets: Int
    public var workDuration: TimeInterval
    public var restDuration: TimeInterval

    public init(sets: Int = 4, workDuration: TimeInterval = 60, restDuration: TimeInterval = 30) {
        self.sets = sets
        self.workDuration = workDuration
        self.restDuration = restDuration
    }
}

// MARK: - IntervalTimerViewModel

@MainActor
public final class IntervalTimerViewModel: ObservableObject {

    // MARK: Published State

    @Published public var phase: TimerPhase = .idle
    @Published public var config: TimerConfiguration = .init()
    @Published public var currentSet: Int = 1
    @Published public var timeRemaining: TimeInterval = 0
    @Published public var progress: Double = 0  // 0.0 -> 1.0
    @Published public var completedWorkTime: TimeInterval = 0  // FN5

    // MARK: Private Core State

    /// NFN1: The authoritative end-time of the current phase.
    /// All countdown logic is derived from Date math against this value.
    private var targetEndDate: Date = .now
    private var phaseDuration: TimeInterval = 0

    /// Accumulated actual work time for the session (excluding pauses).
    private var workStartDate: Date?
    private var accumulatedWorkTime: TimeInterval = 0

    /// Remaining time when app moves to background (for pause during background).
    private var backgroundRemainingTime: TimeInterval?

    /// NFN4: 3-second warning tracking
    private var hasTriggeredWarning = false

    // MARK: Infrastructure

    /// UI-only display timer at ~10 FPS. NOT used for logic (NFN1).
    private var displayTimer: Timer?

    /// Store only the ID (a String) to avoid carrying non-Sendable Activity<T> across actor boundaries.
    private var liveActivityId: String?

    private var audioPlayer: AVAudioPlayer?
    private let hapticLight = UIImpactFeedbackGenerator(style: .light)
    private let hapticHeavy = UIImpactFeedbackGenerator(style: .heavy)

    public init() {
        setupAudioSession()
        hapticLight.prepare()
        hapticHeavy.prepare()
    }

    // MARK: - Public Control API

    public func start() {
        guard phase == .idle else { return }
        currentSet = 1
        accumulatedWorkTime = 0
        completedWorkTime = 0
        beginWorkPhase()
    }

    public func pauseOrResume() {
        switch phase {
        case .working:
            pauseFromWork()
        case .resting:
            pauseFromRest()
        case .paused(let resumePhase):
            resume(from: resumePhase)
        default:
            break
        }
    }

    /// FN3: Skip rest — jump immediately into the next set's work phase.
    public func skipRest() {
        guard case .resting = phase else { return }
        stopDisplayTimer()
        endRestPhase()
    }

    public func reset() {
        stopDisplayTimer()
        endLiveActivity()
        stopAudio()
        phase = .idle
        currentSet = 1
        timeRemaining = 0
        progress = 0
        completedWorkTime = 0
        accumulatedWorkTime = 0
        workStartDate = nil
        hasTriggeredWarning = false
    }

    // MARK: - ScenePhase Handlers (NFN1)

    /// Called when app moves to background.
    public func handleBackground() {
        // Store remaining time; display timer will be suspended by OS anyway.
        if phase == .working || phase == .resting {
            backgroundRemainingTime = targetEndDate.timeIntervalSinceNow
        }
        stopDisplayTimer()
    }

    /// Called when app returns to foreground.
    public func handleForeground() {
        switch phase {
        case .working, .resting:
            // NFN1: Recalculate from targetEndDate — no drift.
            let remaining = max(0, targetEndDate.timeIntervalSinceNow)
            if remaining <= 0 {
                // Phase completed while in background — advance state.
                if case .working = phase {
                    finishWorkPhase()
                } else {
                    endRestPhase()
                }
            } else {
                startDisplayTimer()
            }
        default:
            break
        }
    }

    // MARK: - Phase Transitions

    private func beginWorkPhase() {
        hasTriggeredWarning = false
        phaseDuration = config.workDuration
        targetEndDate = .now.addingTimeInterval(phaseDuration)
        phase = .working
        workStartDate = .now

        startDisplayTimer()
        startLiveActivity()
    }

    private func finishWorkPhase() {
        stopDisplayTimer()

        // Accumulate actual work time.
        if let start = workStartDate {
            accumulatedWorkTime += Date.now.timeIntervalSince(start)
            workStartDate = nil
        }

        triggerPhaseTransitionFeedback()

        if currentSet >= config.sets {
            // All sets done.
            completedWorkTime = accumulatedWorkTime
            phase = .completed
            endLiveActivity()
        } else {
            beginRestPhase()
        }
    }

    private func beginRestPhase() {
        hasTriggeredWarning = false
        phaseDuration = config.restDuration
        targetEndDate = .now.addingTimeInterval(phaseDuration)
        phase = .resting

        startDisplayTimer()
        updateLiveActivity()
    }

    private func endRestPhase() {
        stopDisplayTimer()
        triggerPhaseTransitionFeedback()

        currentSet += 1
        if currentSet > config.sets {
            completedWorkTime = accumulatedWorkTime
            phase = .completed
            endLiveActivity()
        } else {
            beginWorkPhase()
        }
    }

    // MARK: - Pause / Resume

    private func pauseFromWork() {
        stopDisplayTimer()
        backgroundRemainingTime = targetEndDate.timeIntervalSinceNow
        // Pause accumulation.
        if let start = workStartDate {
            accumulatedWorkTime += Date.now.timeIntervalSince(start)
            workStartDate = nil
        }
        phase = .paused(resumePhase: .work)
    }

    private func pauseFromRest() {
        stopDisplayTimer()
        backgroundRemainingTime = targetEndDate.timeIntervalSinceNow
        phase = .paused(resumePhase: .rest)
    }

    private func resume(from pausedPhase: PausedPhase) {
        let remaining = backgroundRemainingTime ?? (pausedPhase == .work ? config.workDuration : config.restDuration)
        targetEndDate = .now.addingTimeInterval(remaining)
        backgroundRemainingTime = nil
        hasTriggeredWarning = remaining <= 3  // Don't re-trigger if we resumed under 3s.

        switch pausedPhase {
        case .work:
            workStartDate = .now
            phase = .working
        case .rest:
            phase = .resting
        }
        startDisplayTimer()
    }

    // MARK: - Display Timer (UI only)

    private func startDisplayTimer() {
        stopDisplayTimer()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    private func stopDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = nil
    }

    /// NFN1: All countdown logic uses Date math against targetEndDate.
    private func tick() {
        let remaining = max(0, targetEndDate.timeIntervalSinceNow)
        timeRemaining = remaining
        progress = phaseDuration > 0 ? max(0, min(1, 1.0 - (remaining / phaseDuration))) : 1.0

        // FN4: 3-second warning
        if remaining <= 3 && remaining > 0 && !hasTriggeredWarning {
            hasTriggeredWarning = true
            triggerWarningFeedback()
        }

        // Phase completion check.
        if remaining <= 0 {
            if case .working = phase {
                finishWorkPhase()
            } else if case .resting = phase {
                endRestPhase()
            }
        }
    }

    // MARK: - Audio & Haptics

    private func setupAudioSession() {
        do {
            // NFN4: duckOthers allows Spotify/Music to lower volume during beep.
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[Timer] AVAudioSession setup failed: \(error)")
        }
    }

    /// FN4: 3-second warning — beep + haptic.
    private func triggerWarningFeedback() {
        hapticLight.impactOccurred()
        playSystemBeep()
    }

    /// Phase transition — strong haptic.
    private func triggerPhaseTransitionFeedback() {
        hapticHeavy.impactOccurred()
    }

    private func playSystemBeep() {
        // Use system sound 1057 (short "tink") — non-intrusive for gym use.
        // AVAudioSession duckOthers is active so background music lowers.
        AudioServicesPlaySystemSound(1057)
    }

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // MARK: - ActivityKit (NFN2)

    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attrs = TimerLiveActivityAttributes(
            workDuration: config.workDuration,
            restDuration: config.restDuration
        )
        let state = TimerLiveActivityAttributes.ContentState(
            targetEndDate: targetEndDate,
            phase: .work,
            currentSet: currentSet,
            totalSets: config.sets
        )

        do {
            let activity = try Activity.request(
                attributes: attrs,
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
            liveActivityId = activity.id
        } catch {
            print("[Timer] Failed to start Live Activity: \(error)")
        }
    }

    private func updateLiveActivity() {
        guard let id = liveActivityId else { return }

        let laPhase: TimerLiveActivityAttributes.TimerPhase = {
            if case .resting = phase { return .rest }
            return .work
        }()

        let newState = TimerLiveActivityAttributes.ContentState(
            targetEndDate: targetEndDate,
            phase: laPhase,
            currentSet: currentSet,
            totalSets: config.sets
        )
        let content = ActivityContent(state: newState, staleDate: nil)
        Task {
            // Lookup by ID at call site — avoids crossing actor boundary with Activity<T>.
            if let act = Activity<TimerLiveActivityAttributes>.activities.first(where: { $0.id == id }) {
                await act.update(content)
            }
        }
    }

    private func endLiveActivity() {
        guard let id = liveActivityId else { return }
        liveActivityId = nil
        Task {
            if let act = Activity<TimerLiveActivityAttributes>.activities.first(where: { $0.id == id }) {
                let finalContent = ActivityContent(state: act.content.state, staleDate: nil)
                await act.end(finalContent, dismissalPolicy: .immediate)
            }
        }
    }
}
