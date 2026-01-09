import SwiftUI

@main
struct RyansCutsApp: App {
    @StateObject private var viewModel = BookingViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(authViewModel)
        }
    }
}
