import Foundation
import Supabase




// MARK: - Service

class BookingService {
    static let shared = BookingService()
    
    private init() {}
    
    
    
    func submitBooking(booking: Booking) async throws {
        // 1. Tell Supabase which table to target
        try await supabase
            .from("bookings")
            // 2. Pass the Swift object (it converts to JSON automatically)
            .insert(booking)
            // 3. Execute the network request
            .execute()
        
        print("✅ Booking successfully submitted to Supabase")
    }
    
    
}
