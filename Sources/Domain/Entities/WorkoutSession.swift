import Foundation

public enum WorkoutType: String, Codable, Sendable {
    case push
    case pull
    case legs
    case rest
}

public struct WorkoutSession: Identifiable, Codable, Sendable {
    public let id: UUID
    public let type: WorkoutType
    public let date: Date
    public let isCompleted: Bool
    
    public init(id: UUID = UUID(), type: WorkoutType, date: Date, isCompleted: Bool = false) {
        self.id = id
        self.type = type
        self.date = date
        self.isCompleted = isCompleted
    }
}
