//
//  Sequence.swift
//  You Done
//
//  Created by Piotr Galar on 11/12/2020.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
