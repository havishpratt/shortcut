import Foundation

struct TimeSlot: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let hour: Int
    
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        let slotDate = Calendar.current.date(from: components)!
        return formatter.string(from: slotDate)
    }
}
