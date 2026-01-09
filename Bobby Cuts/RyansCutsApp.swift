import SwiftUI
import Supabase

@main
struct RyansCutsApp: App {
    @StateObject private var viewModel = BookingViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(authViewModel)
                .onOpenURL { url in
                    print("🔗 App opened with URL: \(url)")
                    
                    Task {
                        do {
                            // 1. Give the URL to Supabase to extract the session
                            let session = try await supabase.auth.session(from: url)
                            
                            // 2. If successful, use the callback handler to extract all user info
                            await MainActor.run {
                                print("✅ Login Successful! User: \(session.user.email ?? "Unknown")")
                                authViewModel.handleGoogleCallback(session: session)
                            }
                        } catch {
                            print("❌ Login Failed: \(error)")
                            await MainActor.run {
                                authViewModel.errorMessage = "Login failed: \(error.localizedDescription)"
                            }
                        }
                    }
                }
        }
    }
}
