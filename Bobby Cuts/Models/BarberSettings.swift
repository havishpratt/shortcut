//
//  BarberSettings.swift
//  Bobby Cuts
//
//  Created by Havish on 1/8/26.
//

struct BarberSettings: Codable {
    let maxCutsPerDay: Int
    
    enum CodingKeys: String, CodingKey {
        case maxCutsPerDay = "max_cuts_per_day"
    }
}
