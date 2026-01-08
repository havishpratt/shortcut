//
//  Untitled.swift
//  Bobby Cuts
//
//  Created by Havish on 1/8/26.
//

import Foundation
// In the database, you'll have 7 rows, one for each day.
struct DailySchedule: Codable {
    let id: UUID
    let dayOfWeek: Int // 1 = Sunday, 2 = Monday...
    var isOpen: Bool
    var startHour: Int // 0-23 (e.g., 16 for 4 PM)
    var endHour: Int   // 0-23 (e.g., 20 for 8 PM)
    
    enum CodingKeys: String, CodingKey {
        case id
        case dayOfWeek = "day_of_week"
        case isOpen = "is_open"
        case startHour = "start_hour"
        case endHour = "end_hour"
    }
}
