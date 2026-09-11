import Foundation
import Domain
import Data
import Presentation

@MainActor
public final class AppDIContainer {
    public static let shared = AppDIContainer()
    
    public let workoutRepository: WorkoutRepository
    public let workoutCycleUseCase: WorkoutCycleUseCase
    
    private init() {
        self.workoutRepository = WorkoutRepositoryImpl()
        self.workoutCycleUseCase = WorkoutCycleUseCaseImpl(repository: workoutRepository)
    }
}
