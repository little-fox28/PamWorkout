import Foundation

public protocol WorkoutCycleUseCase: Sendable {
    func getNextWorkoutType(after current: WorkoutType?) -> WorkoutType
    func startNextWorkout() async throws -> WorkoutSession
}

public final class WorkoutCycleUseCaseImpl: WorkoutCycleUseCase, Sendable {
    private let repository: WorkoutRepository
    
    public init(repository: WorkoutRepository) {
        self.repository = repository
    }
    
    public func getNextWorkoutType(after current: WorkoutType?) -> WorkoutType {
        guard let current = current else { return .push }
        switch current {
        case .push: return .pull
        case .pull: return .legs
        case .legs: return .rest
        case .rest: return .push
        }
    }
    
    public func startNextWorkout() async throws -> WorkoutSession {
        let current = try await repository.getCurrentWorkout()
        let nextType = getNextWorkoutType(after: current?.type)
        
        let newSession = WorkoutSession(type: nextType, date: Date())
        try await repository.saveWorkout(newSession)
        
        return newSession
    }
}
