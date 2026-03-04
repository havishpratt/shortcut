import SwiftUI

struct AdminDashboardView: View {
    @StateObject private var adminVM = AdminViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var viewModel: BookingViewModel
    @State private var isPreviewingCustomer = false

    var body: some View {
        ZStack {
            if isPreviewingCustomer {
                // Show customer view with back button overlay
                HomeView()
                    .overlay(alignment: .topTrailing) {
                        Button {
                            withAnimation { isPreviewingCustomer = false }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.left")
                                Text("Admin")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppTheme.accent)
                            .cornerRadius(20)
                            .shadow(radius: 4)
                        }
                        .padding(.top, 12)
                        .padding(.trailing, 16)
                    }
            } else {
                AppBackground()

                TabView {
                    AdminBookingsView()
                        .tabItem {
                            Label("Bookings", systemImage: "calendar.badge.clock")
                        }
                        .badge(adminVM.pendingBookings.count)

                    AdminScheduleView()
                        .tabItem {
                            Label("Schedule", systemImage: "clock")
                        }

                    AdminSettingsView(onPreviewCustomer: {
                        withAnimation { isPreviewingCustomer = true }
                    })
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .environmentObject(adminVM)
                .accentColor(AppTheme.accent)
            }
        }
        .task {
            await adminVM.loadAll()
        }
    }
}
