//
//  BarberSettings.swift
//  Bobby Cuts
//
//  Created by Havish on 1/8/26.
//

struct BarberSettings: Codable {
    let maxCutsPerDay: Int
    let slotDurationMinutes: Int
    let autoApprove: Bool

    enum CodingKeys: String, CodingKey {
        case maxCutsPerDay = "max_cuts_per_day"
        case slotDurationMinutes = "slot_duration_minutes"
        case autoApprove = "auto_approve"
    }
}
