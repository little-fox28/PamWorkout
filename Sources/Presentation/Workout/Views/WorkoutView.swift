import SwiftUI
import Core
import Domain

public struct WorkoutView: View {
    let useCase: WorkoutCycleUseCase
    @State private var nextWorkoutType: WorkoutType = .push
    
    public init(useCase: WorkoutCycleUseCase) {
        self.useCase = useCase
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            Text(String(localized: "welcome_message", bundle: .core))
                .font(Theme.Typography.title)
                .foregroundColor(Theme.Colors.textPrimary)
                
            Text("Next Workout: \(nextWorkoutType.rawValue.capitalized)")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                
            Button(action: {
                Task {
                    do {
                        let session = try await useCase.startNextWorkout()
                        nextWorkoutType = useCase.getNextWorkoutType(after: session.type)
                    } catch {
                        print(error)
                    }
                }
            }) {
                Text("Start Workout")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.Colors.primaryAccent)
                    .foregroundColor(Theme.Colors.background)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Theme.Colors.background.ignoresSafeArea())
        .onAppear {
            nextWorkoutType = useCase.getNextWorkoutType(after: nil) // Simplified for scaffolding
        }
    }
}
