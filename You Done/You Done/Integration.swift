//
//  Integration.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import Foundation

struct Integration: Identifiable {
    var id: UUID = UUID()
    var name: String
    var state: State

    enum State: String, CaseIterable {
        case installed = "Installed"
        case available = "Available"
    }
}
