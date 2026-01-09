import SwiftUI

struct BookingConfirmationView: View {
    @EnvironmentObject var viewModel: BookingViewModel
    let booking: Booking
    @State private var appeared = false
    @State private var checkmarkScale: CGFloat = 0
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d 'at' h:mm a"
        return formatter.string(from: booking.date)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Success Animation
                VStack(spacing: 16) {
                    Text("🎉")
                        .font(.system(size: 60))
                        .scaleEffect(checkmarkScale)
                    
                    Text("You're Booked!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("We'll confirm your appointment soon")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.top, 20)
                
                // Status message
                if !viewModel.statusMessage.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.success)
                        
                        Text(viewModel.statusMessage)
                            .font(.caption)
                            .foregroundColor(AppTheme.success)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppTheme.success.opacity(0.1))
                    .cornerRadius(20)
                }
                
                // Booking Details Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Details")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    VStack(spacing: 12) {
                        ConfirmationRow(icon: "person.fill", label: "Name", value: booking.customerName)
                        ConfirmationRow(icon: "calendar", label: "When", value: formattedDate)
                        ConfirmationRow(icon: "scissors", label: "Service", value: "Haircut · $15")
                        ConfirmationRow(icon: "envelope.fill", label: "Email", value: booking.customerEmail)
                    }
                    
                    // Status
                    HStack {
                        Text("Status")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(AppTheme.warning)
                                .frame(width: 8, height: 8)
                            
                            Text("Pending")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppTheme.warning)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(20)
                .background(AppTheme.backgroundCard)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                // What's Next
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's Next?")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    VStack(spacing: 12) {
                        StepRow(number: 1, text: "We check the schedule")
                        StepRow(number: 2, text: "You get a confirmation email")
                        StepRow(number: 3, text: "Come through for your cut!")
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.backgroundCard)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15), value: appeared)
                
                // Back Button
                Button(action: {
                    viewModel.currentBooking = nil
                }) {
                    Text("Back to Home")
                }
                .buttonStyle(SecondaryButtonStyle())
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.25), value: appeared)
            }
            .padding(20)
            .padding(.bottom, 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                checkmarkScale = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
        }
    }
}

struct ConfirmationRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.accent)
                .frame(width: 20)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct StepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.1))
                    .frame(width: 28, height: 28)
                
                Text("\(number)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.accent)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
        }
    }
}

struct BookingConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyBooking = Booking(
            id: UUID(),
            date: Date(),
            customerName: "John Doe",
            customerPhone: "123-456-7890",
            customerEmail: "john@example.com",
            status: .pending
        )
        
        ZStack {
            AppBackground()
            BookingConfirmationView(booking: dummyBooking)
                .environmentObject(BookingViewModel())
        }
    }
}
            