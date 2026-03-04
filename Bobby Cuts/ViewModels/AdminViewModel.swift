import SwiftUI
import Combine

@MainActor
class AdminViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var weeklySchedule: [WeeklySchedule] = []
    @Published var settings: BarberSettings?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = BookingService.shared

    var pendingBookings: [Booking] {
        bookings.filter { $0.status == .pending }
    }

    var confirmedBookings: [Booking] {
        bookings.filter { $0.status == .confirmed }
    }

    var deniedBookings: [Booking] {
        bookings.filter { $0.status == .denied }
    }

    // MARK: - Load All Data

    func loadAll() async {
        isLoading = true
        errorMessage = nil

        do {
            async let fetchedBookings = service.fetchAllBookings()
            async let fetchedSchedule = service.fetchWeeklySchedule()
            async let fetchedSettings = service.fetchSettings()

            bookings = try await fetchedBookings
            weeklySchedule = try await fetchedSchedule
            settings = try await fetchedSettings
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
            print("Admin load error: \(error)")
        }

        isLoading = false
    }

    // MARK: - Booking Actions

    func confirmBooking(_ booking: Booking) async {
        do {
            try await service.updateBookingStatus(id: booking.id, status: .confirmed)
            if let index = bookings.firstIndex(where: { $0.id == booking.id }) {
                bookings[index].status = .confirmed
            }
        } catch {
            errorMessage = "Failed to confirm booking: \(error.localizedDescription)"
        }
    }

    func denyBooking(_ booking: Booking) async {
        do {
            try await service.updateBookingStatus(id: booking.id, status: .denied)
            if let index = bookings.firstIndex(where: { $0.id == booking.id }) {
                bookings[index].status = .denied
            }
        } catch {
            errorMessage = "Failed to deny booking: \(error.localizedDescription)"
        }
    }

    // MARK: - Schedule Actions

    func updateScheduleDay(_ schedule: WeeklySchedule) async {
        do {
            try await service.updateScheduleDay(
                dayOfWeek: schedule.dayOfWeek,
                startHour: schedule.startHour,
                endHour: schedule.endHour,
                isActive: schedule.isActive
            )
            if let index = weeklySchedule.firstIndex(where: { $0.dayOfWeek == schedule.dayOfWeek }) {
                weeklySchedule[index] = schedule
            }
        } catch {
            errorMessage = "Failed to update schedule: \(error.localizedDescription)"
        }
    }

    // MARK: - Settings Actions

    func updateSettings(maxCuts: Int, slotDuration: Int) async {
        do {
            try await service.updateSettings(maxCutsPerDay: maxCuts, slotDurationMinutes: slotDuration)
            settings = BarberSettings(maxCutsPerDay: maxCuts, slotDurationMinutes: slotDuration, autoApprove: settings?.autoApprove ?? false)
        } catch {
            errorMessage = "Failed to update settings: \(error.localizedDescription)"
        }
    }
}
