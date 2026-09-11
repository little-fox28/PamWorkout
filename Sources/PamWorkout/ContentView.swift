import SwiftUI
import Core
import Presentation

struct ContentView: View {
    var body: some View {
        TabView {
            IntervalTimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }

            WorkoutView(useCase: AppDIContainer.shared.workoutCycleUseCase)
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                }
                
            SettingView()
                .tabItem{
                    Label("Setting", systemImage: "gear")
                }
        }
        .accentColor(Theme.Colors.primaryAccent)
        .preferredColorScheme(.dark)
    }
}
