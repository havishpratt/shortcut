import Foundation

enum BookingStatus: String, Codable {
    case pending
    case confirmed
    case denied
}

struct Booking: Identifiable, Codable {
    let id: UUID
    let date: Date
    let customerName: String
    let customerPhone: String
    let customerEmail: String
    var status: BookingStatus
    
    // Mapping Swift names to Database columns (snake_case)
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case customerName = "customer_name"
        case customerPhone = "customer_phone"
        case customerEmail = "customer_email"
        case status
    }
}

extension Date {
    func toLocalTime() -> String {
        let formatter = DateFormatter()
        // This automatically detects if the user is in Maryland or Italy
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "h:mm a" // Shows "4:00 PM"
        return formatter.string(from: self)
    }
}
