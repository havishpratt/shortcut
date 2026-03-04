import SwiftUI

struct AdminSettingsView: View {
    @EnvironmentObject var adminVM: AdminViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    var onPreviewCustomer: (() -> Void)?

    @State private var maxCuts: Int = 1
    @State private var slotDuration: Int = 60
    @State private var hasChanges = false
    @State private var showSaved = false

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                Text("Settings")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 16) {
                        // Max cuts per day
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Max Bookings Per Day")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)

                            Stepper(value: $maxCuts, in: 1...20) {
                                Text("\(maxCuts)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppTheme.accent)
                            }
                            .tint(AppTheme.accent)
                            .onChange(of: maxCuts) { _ in hasChanges = true }
                        }
                        .cardStyle()

                        // Slot duration
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Slot Duration")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)

                            Picker("Duration", selection: $slotDuration) {
                                Text("30 min").tag(30)
                                Text("45 min").tag(45)
                                Text("60 min").tag(60)
                                Text("90 min").tag(90)
                            }
                            .pickerStyle(.segmented)
                            .colorScheme(.dark)
                            .onChange(of: slotDuration) { _ in hasChanges = true }
                        }
                        .cardStyle()

                        // Save button
                        if hasChanges {
                            Button("Save Changes") {
                                Task {
                                    await adminVM.updateSettings(maxCuts: maxCuts, slotDuration: slotDuration)
                                    hasChanges = false
                                    showSaved = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showSaved = false
                                    }
                                }
                            }
                            .buttonStyle(AccentButtonStyle())
                            .padding(.horizontal, 16)
                        }

                        if showSaved {
                            Text("Settings saved")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.success)
                                .transition(.opacity)
                        }

                        if let error = adminVM.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.error)
                                .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 40)

                        // Preview as customer
                        Button {
                            onPreviewCustomer?()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "eye")
                                Text("Preview as Customer")
                            }
                        }
                        .buttonStyle(AccentButtonStyle())
                        .padding(.horizontal, 16)

                        // Sign out
                        Button("Sign Out") {
                            authViewModel.signOut()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if let settings = adminVM.settings {
                maxCuts = settings.maxCutsPerDay
                slotDuration = settings.slotDurationMinutes
            }
        }
        .onChange(of: adminVM.settings?.maxCutsPerDay) { newValue in
            if let value = newValue {
                maxCuts = value
                hasChanges = false
            }
        }
    }
}
