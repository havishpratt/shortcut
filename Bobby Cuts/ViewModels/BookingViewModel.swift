import SwiftUI
import Combine

class BookingViewModel: ObservableObject {
    @Published var bookedSlots: [String: Bool] = [:] // Local optimistic cache
    @Published var currentBooking: Booking?
    @Published var statusMessage: String = ""
    @Published var isProcessing: Bool = false
    @Published var occupiedHours: Set<Int> = [] // Hours that are already taken on the selected date
    @Published var isLoadingSlots: Bool = false
    
    // Default Schedule (Fallback until we load from DB)
    let businessDays: Set<Int> = [3, 4, 5, 6, 7] // Tue-Sat
    let businessHours = Array(16...19) // 4pm-8pm
    let bookingWindowDays = 14
    
    private let service = BookingService.shared
    
    // 🌍 TIMEZONE FIX: Force everything to Shop Time (EST/New York)
    private var shopCalendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        if let timeZone = TimeZone(identifier: "America/New_York") {
            cal.timeZone = timeZone
        }
        return cal
    }()
    
    // MARK: - Date Selection
    
    func getAvailableDates() -> [Date] {
        var dates: [Date] = []
        // Use shopCalendar for "Today" so we see the Shop's day, not India's day
        let today = shopCalendar.startOfDay(for: Date())
        
        for i in 0..<bookingWindowDays {
            if let date = shopCalendar.date(byAdding: .day, value: i, to: today) {
                let weekday = shopCalendar.component(.weekday, from: date)
                if businessDays.contains(weekday) {
                    dates.append(date)
                }
            }
        }
        return dates
    }
    
    // MARK: - Slot Selection
    
    /// Called when the user taps a date. Fetches real bookings from Supabase.
    @MainActor
    func loadAvailability(for date: Date) async {
        isLoadingSlots = true
        occupiedHours.removeAll()
        
        do {
            let takenDates = try await service.fetchExistingBookings(for: date)
            
            // Extract just the hour from the full dates using Shop Calendar
            let hours = takenDates.map { shopCalendar.component(.hour, from: $0) }
            
            occupiedHours = Set(hours)
            print("📅 Loaded availability for \(date): Occupied Hours: \(occupiedHours)")
            
        } catch {
            // Ignore cancellation errors (happens when quickly scrolling/navigating)
            if (error as NSError).code == -999 { return }
            print("❌ Failed to load availability: \(error)")
        }
        
        isLoadingSlots = false
    }
    
    func getAvailableSlots(for date: Date) -> [TimeSlot] {
        let now = Date()
        
        return businessHours.compactMap { hour in
            // 1. Check if this hour is already taken in the DB
            if occupiedHours.contains(hour) {
                return nil
            }
            
            var components = shopCalendar.dateComponents([.year, .month, .day], from: date)
            components.hour = hour
            
            guard let slotDate = shopCalendar.date(from: components) else { return nil }
            
            // 2. Don't show past slots for today (Comparing using Date() is safe as it is UTC point in time)
            // But we check if "date" is today relative to Shop
            if shopCalendar.isDateInToday(date) && slotDate < now {
                return nil
            }
            
            // 3. Check local optimistic cache (just in case they booked 2 seconds ago)
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
        formatter.timeZone = TimeZone(identifier: "America/New_York") // Force formatter to Shop Time
        return "\(formatter.string(from: date))-\(hour)"
    }
    
    // MARK: - Booking Action
    
    func bookSlot(date: Date, hour: Int, name: String, phone: String, email: String) {
        let key = slotKey(date: date, hour: hour)
        isProcessing = true
        
        var components = shopCalendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        let bookingDate = shopCalendar.date(from: components)!
        
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
        print("   You selected Hour: \(hour) (Shop Time)")
        print("   Shop Calendar Time: \(bookingDate)")
        
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
