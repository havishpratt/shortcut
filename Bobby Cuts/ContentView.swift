import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: BookingViewModel
    
    var body: some View {
        NavigationView {
            HomeView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(BookingViewModel())
    }
}
