//
//  Task.swift
//  You Done
//
//  Created by Piotr Galar on 09/12/2020.
//

import SwiftUI

struct Task: Identifiable, Equatable, Hashable {
    var id: String = UUID().description
    var text: String
    var deleted: Bool = false
}
