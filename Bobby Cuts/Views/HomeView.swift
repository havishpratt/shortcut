import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: BookingViewModel
    @State private var headerOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            AppBackground()
            
            VStack(spacing: 0) {
                // Casual Header
                VStack(spacing: 12) {
                    // Fun emoji header
                    Text("✂️")
                        .font(.system(size: 50))
                    
                    Text("Barber Cuts")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Premium Grooming Experience")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    // Price tag
                    Text("$15 · 1 Hour")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.accent.opacity(0.15))
                        .cornerRadius(20)
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                .opacity(headerOpacity)
                
                // Main Content
                if let booking = viewModel.currentBooking {
                    BookingConfirmationView(booking: booking)
                } else {
                    DateSelectionView()
                }
                
                Spacer(minLength: 0)
                
                // Contact Button
                ContactRyanButton()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                headerOpacity = 1.0
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(BookingViewModel())
    }
}
