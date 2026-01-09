import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: BookingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isOnboarding {
                OnboardingView()
            } else {
                NavigationView {
                    HomeView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(BookingViewModel())
            .environmentObject(AuthViewModel())
    }
}
