import SwiftUI

struct BookingConfirmationView: View {
    @EnvironmentObject var viewModel: BookingViewModel
    let booking: Booking
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d 'at' h:mm a"
        return formatter.string(from: booking.date)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Status Icon
                Image(systemName: "clock.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.orange)
                    .padding(.top, 32)
                
                Text("Request Sent")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Ryan will review your appointment request shortly.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Debug Message (If Any)
                if !viewModel.statusMessage.isEmpty {
                    Text(viewModel.statusMessage)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Booking Details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(icon: "person.fill", label: "Name", value: booking.customerName)
                    DetailRow(icon: "calendar", label: "Requested Date", value: formattedDate)
                    DetailRow(icon: "scissors", label: "Service", value: "Men's Haircut")
                    DetailRow(icon: "envelope", label: "Notification", value: "You'll be emailed at \(booking.customerEmail)")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("What Happens Next?")
                        .font(.headline)
                    
                    HStack(alignment: .top) {
                        Image(systemName: "1.circle.fill")
                            .foregroundColor(.secondary)
                        Text("Ryan receives your request.")
                    }
                    HStack(alignment: .top) {
                        Image(systemName: "2.circle.fill")
                            .foregroundColor(.secondary)
                        Text("Once approved, you'll receive a confirmation email with a calendar invite.")
                    }
                    HStack(alignment: .top) {
                        Image(systemName: "3.circle.fill")
                            .foregroundColor(.secondary)
                        Text("Payment can be made at the shop.")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // New Booking Button
                Button(action: {
                    viewModel.currentBooking = nil
                }) {
                    Text("Back to Home")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                        }
                    }
                }
            }
            
            struct BookingConfirmationView_Previews: PreviewProvider {
                static var previews: some View {
                    let dummyBooking = Booking(
                        id: UUID(),
                        date: Date(),
                        customerName: "Test User",
                        customerPhone: "123-456-7890",
                        customerEmail: "test@example.com",
                        status: .pending
                    )
                    
                    BookingConfirmationView(booking: dummyBooking)
                        .environmentObject(BookingViewModel())
                }
            }
            