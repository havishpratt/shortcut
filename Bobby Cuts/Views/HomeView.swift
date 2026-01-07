import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: BookingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Ryan's Cuts")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Premium Men's Haircuts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("1 Hour Service")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            
            Divider()
            
            // Main Content
            if let booking = viewModel.currentBooking {
                BookingConfirmationView(booking: booking)
            } else {
                DateSelectionView()
            }
            
            Spacer()
            
            // Contact Button
            ContactRyanButton()
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
        .navigationBarHidden(true)
    }
}
