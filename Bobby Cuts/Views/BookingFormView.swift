import SwiftUI

struct BookingFormView: View {
    @EnvironmentObject var viewModel: BookingViewModel
    @Environment(\.dismiss) var dismiss
    let slot: TimeSlot
    
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    
    var isFormValid: Bool {
        !name.isEmpty && !phone.isEmpty && !email.isEmpty && email.contains("@")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Booking Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Booking Summary")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text(slot.date, style: .date)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text(slot.displayTime)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "scissors")
                        Text("Men's Haircut")
                    }
                    .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Customer Info
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Information")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            TextField("Full Name", text: $name)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        
                        HStack {
                            Image(systemName: "phone")
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            TextField("Phone Number", text: $phone)
                                .keyboardType(.phonePad)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }
                
                // Book Button
                Button(action: {
                    viewModel.bookSlot(
                        date: slot.date,
                        hour: slot.hour,
                        name: name,
                        phone: phone,
                        email: email
                    )
                    // We dismiss immediately for better UX, viewModel handles background task
                    dismiss()
                }) {
                    HStack {
                        if viewModel.isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Book Appointment")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!isFormValid || viewModel.isProcessing)
            }
            .padding()
        }
        .navigationTitle("Complete Booking")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BookingFormView_Previews: PreviewProvider {
    static var previews: some View {
        let dummySlot = TimeSlot(date: Date(), hour: 12)
        NavigationView {
            BookingFormView(slot: dummySlot)
                .environmentObject(BookingViewModel())
        }
    }
}
