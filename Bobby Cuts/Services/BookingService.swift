import Foundation
import Supabase
import Realtime

// MARK: - API Models

struct WeeklySchedule: Codable, Identifiable {
    var id: UUID?
    let dayOfWeek: Int
    var startHour: Int
    var endHour: Int
    var isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case dayOfWeek = "day_of_week"
        case startHour = "start_hour"
        case endHour = "end_hour"
        case isActive = "is_active"
    }
}

// MARK: - Service

class BookingService {
    static let shared = BookingService()
    
    private init() {}
    
    /// Sends a new booking request to Supabase
    func submitBooking(booking: Booking) async throws {
        try await supabase
            .from("bookings")
            .insert(booking)
            .execute()
        
        print("✅ Booking successfully submitted to Supabase")
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
        let settings: BarberSettings = try await supabase
            .from("barber_settings")
            .select()
            .eq("id", value: 1)
            .single()
            .execute()
            .value
            
        return settings
    }
    
    /// Fetches existing bookings for a specific date to prevent double booking
    func fetchExistingBookings(for date: Date) async throws -> [Date] {
        // 1. Force calculation in Shop Time (EST/New York)
        // This prevents timezone bugs where users in different zones see the wrong availability
        var calendar = Calendar.current
        if let shopTimeZone = TimeZone(identifier: "America/New_York") {
            calendar.timeZone = shopTimeZone
        }
        
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        
        // 2. Format dates for PostgreSQL (ISO 8601)
        let formatter = ISO8601DateFormatter()
        // Ensure formatter also uses UTC to match DB expectation or specific offset?
        // Supabase expects UTC usually. But we calculated startOfDay in EST.
        // startOfDay (Jan 8 00:00 EST) -> is Jan 8 05:00 UTC.
        // formatter default is UTC. So it will convert 00:00 EST Date object -> 05:00 Z String. Correct.
        
        // Helper struct to decode just the date column
        struct BookingDateOnly: Decodable {
            let date: Date
        }
        
        // 3. Query - Only fetch bookings that actually block the slot (pending/confirmed)
        let bookings: [BookingDateOnly] = try await supabase
            .from("bookings")
            .select("date")
            .gte("date", value: formatter.string(from: startOfDay))
            .lt("date", value: formatter.string(from: endOfDay))
            .in("status", values: ["pending", "confirmed"])
            .execute()
            .value
            
        return bookings.map { $0.date }
    }
    
    /// Fetches all bookings for a date range (used for preloading)
    func fetchAllBookingsInRange(from startDate: Date, days: Int) async throws -> [Date] {
        var calendar = Calendar.current
        if let shopTimeZone = TimeZone(identifier: "America/New_York") {
            calendar.timeZone = shopTimeZone
        }
        
        let startOfRange = calendar.startOfDay(for: startDate)
        guard let endOfRange = calendar.date(byAdding: .day, value: days, to: startOfRange) else { return [] }
        
        let formatter = ISO8601DateFormatter()
        
        struct BookingDateOnly: Decodable {
            let date: Date
        }
        
        let bookings: [BookingDateOnly] = try await supabase
            .from("bookings")
            .select("date")
            .gte("date", value: formatter.string(from: startOfRange))
            .lt("date", value: formatter.string(from: endOfRange))
            .in("status", values: ["pending", "confirmed"])
            .execute()
            .value
        
        return bookings.map { $0.date }
    }
    
    // MARK: - Admin: Bookings

    func fetchAllBookings() async throws -> [Booking] {
        let bookings: [Booking] = try await supabase
            .from("bookings")
            .select()
            .order("date", ascending: false)
            .execute()
            .value
        return bookings
    }

    func updateBookingStatus(id: UUID, status: BookingStatus) async throws {
        struct StatusUpdate: Encodable {
            let status: String
        }
        try await supabase
            .from("bookings")
            .update(StatusUpdate(status: status.rawValue))
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Admin: Schedule

    func updateScheduleDay(dayOfWeek: Int, startHour: Int, endHour: Int, isActive: Bool) async throws {
        struct ScheduleUpdate: Encodable {
            let start_hour: Int
            let end_hour: Int
            let is_active: Bool
        }
        try await supabase
            .from("weekly_schedule")
            .update(ScheduleUpdate(start_hour: startHour, end_hour: endHour, is_active: isActive))
            .eq("day_of_week", value: dayOfWeek)
            .execute()
    }

    // MARK: - Admin: Settings

    func updateSettings(maxCutsPerDay: Int, slotDurationMinutes: Int) async throws {
        struct SettingsUpdate: Encodable {
            let max_cuts_per_day: Int
            let slot_duration_minutes: Int
        }
        try await supabase
            .from("barber_settings")
            .update(SettingsUpdate(max_cuts_per_day: maxCutsPerDay, slot_duration_minutes: slotDurationMinutes))
            .eq("id", value: 1)
            .execute()
    }

    // MARK: - Realtime
    
    private var realtimeChannel: RealtimeChannelV2?
    private var realtimeTask: Task<Void, Never>?
    
    /// Listens for ANY change to the bookings table and triggers the callback
    func subscribeToBookings(onChange: @escaping @Sendable () -> Void) async {
        // If already subscribed, don't duplicate
        if realtimeChannel != nil { return }
        
        let channel = supabase.realtimeV2.channel("bookings-changes") {
            $0.broadcast.receiveOwnBroadcasts = true
        }
        realtimeChannel = channel
        
        // Set up postgres changes listener before subscribing
        let changes = channel.postgresChange(AnyAction.self, schema: "public", table: "bookings")
        
        // Subscribe to the channel
        do {
            try await channel.subscribeWithError()
            print("✅ Subscribed to Realtime Bookings")
        } catch {
            print("❌ Failed to subscribe to Realtime: \(error)")
            return
        }
        
        // Start listening for changes in a background task
        realtimeTask = Task {
            for await _ in changes {
                print("⚡️ Realtime: Booking change detected")
                await MainActor.run {
                    onChange()
                }
            }
        }
    }
    
    func unsubscribe() async {
        realtimeTask?.cancel()
        realtimeTask = nil
        await realtimeChannel?.unsubscribe()
        realtimeChannel = nil
    }
}
