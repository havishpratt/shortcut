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
}
