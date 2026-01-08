import Foundation

struct TimeSlot: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let hour: Int
    
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        // Force the display to show Shop Time (New York), not the user's local time
        if let shopTimeZone = TimeZone(identifier: "America/New_York") {
            formatter.timeZone = shopTimeZone
        }
        
        // Create the date using the Shop Calendar logic to match the ViewModel
        var calendar = Calendar(identifier: .gregorian)
        if let shopTimeZone = TimeZone(identifier: "America/New_York") {
            calendar.timeZone = shopTimeZone
        }
        
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        
        if let slotDate = calendar.date(from: components) {
            return formatter.string(from: slotDate)
        }
        
        return "\(hour):00" // Fallback
    }
}