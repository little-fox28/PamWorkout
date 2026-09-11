import Foundation

public protocol WorkoutRepository: Sendable {
    func getCurrentWorkout() async throws -> WorkoutSession?
    func saveWorkout(_ session: WorkoutSession) async throws
    func getHistory() async throws -> [WorkoutSession]
}
