//
//  Date.swift
//  You Done
//
//  Created by Piotr Galar on 11/12/2020.
//

import Foundation

extension Date {
    func toDay() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dayString = dateFormatter.string(from: self)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: dayString)!
    }
}
