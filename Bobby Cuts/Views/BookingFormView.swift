import SwiftUI

struct BookingFormView: View {
    @EnvironmentObject var viewModel: BookingViewModel
    @Environment(\.dismiss) var dismiss
    let slot: TimeSlot
    
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var appeared = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, phone, email
    }
    
    var isFormValid: Bool {
        !name.isEmpty && !phone.isEmpty && !email.isEmpty && email.contains("@")
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: slot.date)
    }
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Booking Summary Card
                    VStack(spacing: 16) {
                        HStack {
                            Text("Your Appointment")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            Text("$15")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.accent)
                        }
                        
                        Divider()
                        
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.accent)
                                Text(formattedDate)
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            VStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.accent)
                                Text(slot.displayTime)
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            VStack(spacing: 4) {
                                Image(systemName: "scissors")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.accent)
                                Text("Haircut")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                    .background(AppTheme.backgroundCard)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    
                    // Customer Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Info")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        VStack(spacing: 12) {
                            FormTextField(
                                icon: "person.fill",
                                placeholder: "Name",
                                text: $name
                            )
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .phone }
                            
                            FormTextField(
                                icon: "phone.fill",
                                placeholder: "Phone",
                                text: $phone,
                                keyboardType: .phonePad
                            )
                            .focused($focusedField, equals: .phone)
                            
                            FormTextField(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            .focused($focusedField, equals: .email)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.done)
                        }
                    }
                    .padding(20)
                    .background(AppTheme.backgroundCard)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
                    
                    // Location Note
                    HStack(spacing: 10) {
                        Image(systemName: "building.2")
                            .foregroundColor(AppTheme.accent)
                        
                        Text("Bobby will come to your dorm!")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(AppTheme.accent.opacity(0.08))
                    .cornerRadius(12)
                    .opacity(appeared ? 1 : 0)
                    
                    // Book Button
                    Button(action: {
                        viewModel.bookSlot(
                            date: slot.date,
                            hour: slot.hour,
                            name: name,
                            phone: phone,
                            email: email
                        )
                        dismiss()
                    }) {
                        HStack(spacing: 10) {
                            if viewModel.isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Book It! ✂️")
                            }
                        }
                    }
                    .buttonStyle(AccentButtonStyle(isEnabled: isFormValid))
                    .disabled(!isFormValid || viewModel.isProcessing)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: appeared)
                }
                .padding(20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appeared = true
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
}

struct FormTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.accent)
                .frame(width: 24)
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(AppTheme.textMuted))
                .font(.body)
                .foregroundColor(AppTheme.textPrimary)
                .keyboardType(keyboardType)
        }
        .padding(14)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(12)
    }
}

struct BookingFormView_Previews: PreviewProvider {
    static var previews: some View {
        let dummySlot = TimeSlot(date: Date(), hour: 16)
        NavigationView {
            BookingFormView(slot: dummySlot)
                .environmentObject(BookingViewModel())
        }
    }
}
