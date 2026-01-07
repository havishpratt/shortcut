import Foundation
import Supabase

// MARK: - API Models

struct WeeklySchedule: Codable {
    let dayOfWeek: Int
    let startHour: Int
    let endHour: Int
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case startHour = "start_hour"
        case endHour = "end_hour"
        case isActive = "is_active"
    }
}

struct BarberSettings: Codable {
    let maxCutsPerDay: Int
    
    enum CodingKeys: String, CodingKey {
        case maxCutsPerDay = "max_cuts_per_day"
    }
}

// MARK: - Service

class BookingService {
    static let shared = BookingService()
    
    /// Sends a new booking request to Supabase
    func createBooking(booking: Booking) async throws {
        // The 'booking' struct is Codable, so it automatically converts to JSON matching your table columns
        try await supabase
            .from("bookings")
            .insert(booking)
            .execute()
            
        print("✅ Booking successfully saved to Supabase: \(booking.id)")
    }
    
    /// Fetches Ryan's weekly schedule from the database
    func fetchWeeklySchedule() async throws -> [WeeklySchedule] {
        let schedule: [WeeklySchedule] = try await supabase
            .from("weekly_schedule")
            .select()
            .execute()
            .value
        
        return schedule
    }
    
    /// Fetches global settings (like max cuts per day)
    func fetchSettings() async throws -> BarberSettings {
        // We assume there is always a row with ID 1
        let settings: BarberSettings = try await supabase
            .from("barber_settings")
            .select()
            .eq("id", value: 1)
            .single() // Expecting exactly one result
            .execute()
            .value
            
        return settings
    }
    
    /// Fetches existing bookings for a specific date to prevent double booking
    func fetchExistingBookings(for date: Date) async throws -> [Date] {
        // 1. Calculate start and end of the day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        
        // 2. Format dates for PostgreSQL (ISO 8601)
        let formatter = ISO8601DateFormatter()
        
        struct BookingDateOnly: Decodable {
            let date: Date
        }
        
        // 3. Query: Get all bookings where date is >= startOfDay AND date < endOfDay
        // AND status is NOT 'denied'
        let bookings: [BookingDateOnly] = try await supabase
            .from("bookings")
            .select("date") // We only need the date column
            .gte("date", value: formatter.string(from: startOfDay))
            .lt("date", value: formatter.string(from: endOfDay))
            .neq("status", value: "denied") // Don't count denied bookings as blocking
            .execute()
            .value
            
        return bookings.map { $0.date }
    }
}
