import SwiftUI
import Combine

class BookingViewModel: ObservableObject {
    @Published var bookedSlots: [String: Bool] = [:] // Local optimistic cache
    @Published var currentBooking: Booking?
    @Published var statusMessage: String = ""
    @Published var isProcessing: Bool = false
    @Published var isLoadingSlots: Bool = false
    @Published var isInitialLoading: Bool = true // For app-wide loading state
    
    // Preloaded bookings: key is "yyyy-MM-dd", value is set of occupied hours
    @Published var allOccupiedSlots: [String: Set<Int>] = [:]
    
    // Default Schedule (Fallback until we load from DB)
    let businessDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7] // All Days
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
    
    private var dateKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        return formatter
    }()
    
    init() {
        // Preload all bookings on init
        Task {
            await preloadAllBookings()
        }
    }
    
    // MARK: - Preload All Bookings
    
    @MainActor
    func preloadAllBookings() async {
        isInitialLoading = true
        
        do {
            let today = shopCalendar.startOfDay(for: Date())
            let allBookedDates = try await service.fetchAllBookingsInRange(from: today, days: bookingWindowDays)
            
            // Group bookings by date key and extract hours
            var slotsByDate: [String: Set<Int>] = [:]
            
            for bookedDate in allBookedDates {
                let dateKey = dateKeyFormatter.string(from: bookedDate)
                let hour = shopCalendar.component(.hour, from: bookedDate)
                
                if slotsByDate[dateKey] == nil {
                    slotsByDate[dateKey] = []
                }
                slotsByDate[dateKey]?.insert(hour)
            }
            
            allOccupiedSlots = slotsByDate
            print("📅 Preloaded \(allBookedDates.count) bookings across \(slotsByDate.keys.count) days")
            
        } catch {
            print("❌ Failed to preload bookings: \(error)")
        }
        
        isInitialLoading = false
    }
    
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
    
    /// Get occupied hours for a specific date from preloaded data
    func getOccupiedHours(for date: Date) -> Set<Int> {
        let dateKey = dateKeyFormatter.string(from: date)
        return allOccupiedSlots[dateKey] ?? []
    }
    
    /// Called when the user taps a date. Now uses preloaded data instead of fetching.
    @MainActor
    func loadAvailability(for date: Date) async {
        // Data is already preloaded, just trigger a refresh if needed
        isLoadingSlots = false
    }
    
    func getAvailableSlots(for date: Date) -> [TimeSlot] {
        let now = Date()
        let occupiedHours = getOccupiedHours(for: date)
        
        return businessHours.compactMap { hour in
            // 1. Check if this hour is already taken in the preloaded data
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
    
    /// Get count of available slots for a date (for display in date cards)
    func getAvailableSlotsCount(for date: Date) -> Int {
        return getAvailableSlots(for: date).count
    }
    
    func slotKey(date: Date, hour: Int) -> String {
        return "\(dateKeyFormatter.string(from: date))-\(hour)"
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
        
        // Also update preloaded data
        let dateKey = dateKeyFormatter.string(from: date)
        if allOccupiedSlots[dateKey] == nil {
            allOccupiedSlots[dateKey] = []
        }
        allOccupiedSlots[dateKey]?.insert(hour)
        
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
                    self.allOccupiedSlots[dateKey]?.remove(hour)
                    self.currentBooking = nil
                }
            }
        }
    }
}
