import SwiftUI
import Combine

class BookingViewModel: ObservableObject {
    @Published var bookedSlots: [String: Bool] = [:]
    @Published var currentBooking: Booking?
    @Published var statusMessage: String = ""
    @Published var isProcessing: Bool = false
    
    // Default Schedule (Fallback until we load from DB)
    let businessDays: Set<Int> = [3, 4, 5, 6, 7] // Tue-Sat
    let businessHours = Array(16...19) // 4pm-8pm
    let bookingWindowDays = 14
    
    private let service = BookingService.shared
    
    func getAvailableDates() -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<bookingWindowDays {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                let weekday = calendar.component(.weekday, from: date)
                if businessDays.contains(weekday) {
                    dates.append(date)
                }
            }
        }
        return dates
    }
    
    func getAvailableSlots(for date: Date) -> [TimeSlot] {
        let calendar = Calendar.current
        let now = Date()
        
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
        isProcessing = true
        
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
        
        // Optimistic UI Update
        bookedSlots[key] = true
        currentBooking = newBooking
        
        // DEBUG: Check Timezone
        print("🕒 Booking Time Debug:")
        print("   You selected Hour: \(hour)")
        print("   Local Device Time: \(bookingDate.description(with: .current))")
        print("   UTC Time (sent to DB): \(bookingDate)")
        
        // Send to Supabase
        Task {
            do {
                try await service.submitBooking(booking: newBooking)
                await MainActor.run {
                    self.statusMessage = "Booking Sent to Database!"
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.statusMessage = "Error: \(error.localizedDescription)"
                    self.isProcessing = false
                    // Revert if failed
                    self.bookedSlots[key] = false
                    self.currentBooking = nil
                }
            }
        }
    }
}
