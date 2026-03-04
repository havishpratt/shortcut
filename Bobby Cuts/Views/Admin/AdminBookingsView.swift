import SwiftUI

struct AdminBookingsView: View {
    @EnvironmentObject var adminVM: AdminViewModel

    @State private var selectedFilter: BookingFilter = .pending

    enum BookingFilter: String, CaseIterable {
        case pending = "Pending"
        case confirmed = "Confirmed"
        case denied = "Denied"
        case all = "All"
    }

    private var filteredBookings: [Booking] {
        switch selectedFilter {
        case .pending: return adminVM.pendingBookings
        case .confirmed: return adminVM.confirmedBookings
        case .denied: return adminVM.deniedBookings
        case .all: return adminVM.bookings
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        f.timeZone = TimeZone(identifier: "America/New_York")
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.timeZone = TimeZone(identifier: "America/New_York")
        return f
    }()

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Bookings")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)

                    // Filter picker
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(BookingFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .colorScheme(.dark)
                    .padding(.horizontal, 16)
                }
                .padding(.top, 16)
                .padding(.bottom, 12)

                if adminVM.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accent))
                    Spacer()
                } else if filteredBookings.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.textMuted)
                        Text("No \(selectedFilter.rawValue.lowercased()) bookings")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredBookings) { booking in
                                BookingCard(booking: booking)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Booking Card

    @ViewBuilder
    private func BookingCard(booking: Booking) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Customer info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.customerName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(Self.dateFormatter.string(from: booking.date) + " at " + Self.timeFormatter.string(from: booking.date))
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                StatusBadge(status: booking.status)
            }

            // Contact info
            HStack(spacing: 16) {
                Label(booking.customerPhone, systemImage: "phone")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)

                Label(booking.customerEmail, systemImage: "envelope")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
            }

            // Action buttons for pending bookings
            if booking.status == .pending {
                HStack(spacing: 12) {
                    Button("Confirm") {
                        Task { await adminVM.confirmBooking(booking) }
                    }
                    .buttonStyle(AccentButtonStyle())

                    Button("Deny") {
                        Task { await adminVM.denyBooking(booking) }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
        .cardStyle()
    }

    @ViewBuilder
    private func StatusBadge(status: BookingStatus) -> some View {
        let (text, color): (String, Color) = {
            switch status {
            case .pending: return ("Pending", AppTheme.warning)
            case .confirmed: return ("Confirmed", AppTheme.success)
            case .denied: return ("Denied", AppTheme.error)
            }
        }()

        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .cornerRadius(8)
    }
}
