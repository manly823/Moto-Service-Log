import SwiftUI

@main
struct MotoServiceLogApp: App {
    @StateObject private var manager = MotoManager()
    var body: some Scene {
        WindowGroup {
            if manager.settings.hasCompletedOnboarding {
                MainView().environmentObject(manager)
            } else {
                OnboardingView().environmentObject(manager)
            }
        }
    }
}
