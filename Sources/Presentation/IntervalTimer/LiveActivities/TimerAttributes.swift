import ActivityKit
import Foundation

// MARK: - ActivityKit Live Activity Attributes
// Displayed on the Lock Screen and in the Dynamic Island.
public struct TimerLiveActivityAttributes: ActivityAttributes {

    public enum TimerPhase: String, Codable, Sendable {
        case work = "Work"
        case rest = "Rest"
    }

    public struct ContentState: Codable, Hashable, Sendable {
        // System-rendered countdown: iOS renders this natively, no polling needed.
        public var targetEndDate: Date
        public var phase: TimerPhase
        public var currentSet: Int
        public var totalSets: Int

        public init(targetEndDate: Date, phase: TimerPhase, currentSet: Int, totalSets: Int) {
            self.targetEndDate = targetEndDate
            self.phase = phase
            self.currentSet = currentSet
            self.totalSets = totalSets
        }
    }

    // Static data that does not change during the activity lifetime.
    public var workDuration: TimeInterval
    public var restDuration: TimeInterval

    public init(workDuration: TimeInterval, restDuration: TimeInterval) {
        self.workDuration = workDuration
        self.restDuration = restDuration
    }
}
