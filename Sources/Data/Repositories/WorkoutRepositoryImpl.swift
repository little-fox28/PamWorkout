import Foundation
import Domain

// For scaffolding, we use a simple UserDefaults-based persistent store.
public final class WorkoutRepositoryImpl: WorkoutRepository, Sendable {
    private let historyKey = "WorkoutHistory"
    
    public init() {}
    
    public func getCurrentWorkout() async throws -> WorkoutSession? {
        // Return the most recent workout as the "current" reference
        let history = try await getHistory()
        return history.last
    }
    
    public func saveWorkout(_ session: WorkoutSession) async throws {
        var history = try await getHistory()
        // If updating an existing session
        if let index = history.firstIndex(where: { $0.id == session.id }) {
            history[index] = session
        } else {
            history.append(session)
        }
        
        let data = try JSONEncoder().encode(history)
        UserDefaults.standard.set(data, forKey: historyKey)
    }
    
    public func getHistory() async throws -> [WorkoutSession] {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return [] }
        return try JSONDecoder().decode([WorkoutSession].self, from: data)
    }
}
