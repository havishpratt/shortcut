import SwiftUI
import Combine

class BookingViewModel: ObservableObject {
    @Published var bookedSlots: [String: Bool] = [:]
    @Published var currentBooking: Booking?
    @Published var weeklySchedule: [WeeklySchedule] = []
    @Published var settings: BarberSettings?
    @Published var isLoading = false
    
    let bookingWindowDays = 14
    private let service = BookingService.shared
    
    init() {
        Task {
            await loadData()
        }
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        do {
            async let schedule = service.fetchWeeklySchedule()
            async let fetchedSettings = service.fetchSettings()
            
            self.weeklySchedule = try await schedule
            self.settings = try await fetchedSettings
        } catch {
            print("Error loading data: \(error)")
        }
        isLoading = false
    }
    
    func getAvailableDates() -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        let today = Date()
        
        // Map of Day Int (1=Sun) to Schedule
        let scheduleMap = Dictionary(uniqueKeysWithValues: weeklySchedule.map { ($0.dayOfWeek, $0) })
        
        for i in 0..<bookingWindowDays {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                let weekday = calendar.component(.weekday, from: date)
                if let schedule = scheduleMap[weekday], schedule.isActive {
                    dates.append(date)
                }
            }
        }
        return dates
    }
    
    func getAvailableSlots(for date: Date) -> [TimeSlot] {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: date)
        
        guard let schedule = weeklySchedule.first(where: { $0.dayOfWeek == weekday }), schedule.isActive else {
            return []
        }
        
        let businessHours = Array(schedule.startHour..<schedule.endHour)
        
        return businessHours.compactMap { hour in
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = hour
            
            guard let slotDate = calendar.date(from: components) else { return nil }
            
            // Don't show past slots for today
            if calendar.isDateInToday(date) && slotDate < now {
                return nil
            }
            
            let slotKey = slotKey(date: date, hour: hour)
            if bookedSlots[slotKey] == true {
                return nil
            }
            
            return TimeSlot(date: date, hour: hour)
        }
    }
    
    func slotKey(date: Date, hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: date))-\(hour)"
    }
    
    func bookSlot(date: Date, hour: Int, name: String, phone: String, email: String) {
        let key = slotKey(date: date, hour: hour)
        // Optimistic update
        bookedSlots[key] = true
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        let bookingDate = Calendar.current.date(from: components)!
        
        let newBooking = Booking(
            id: UUID(),
            date: bookingDate,
            customerName: name,
            customerPhone: phone,
            customerEmail: email,
            status: .pending
        )
        
        currentBooking = newBooking
        
        Task {
            do {
                try await service.createBooking(booking: newBooking)
            } catch {
                print("Failed to create booking: \(error)")
                // Revert state if error
                DispatchQueue.main.async {
                    self.bookedSlots[key] = false
                }
            }
        }
    }
}