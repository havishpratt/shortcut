import SwiftUI

@main
struct RyansCutsApp: App {
    @StateObject private var viewModel = BookingViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
