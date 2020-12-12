//
//  TextExtension.swift
//  You Done
//
//  Created by Piotr Galar on 12/12/2020.
//

import SwiftUI

extension Text {
    public func bold(_ active: Bool = true) -> Text {
        if (active) {
            return self.bold()
        } else {
            return self
        }
    }

}
