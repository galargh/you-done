//
//  Date.swift
//  You Done
//
//  Created by Piotr Galar on 11/12/2020.
//

import Foundation


extension DateFormatter {
    static func day() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
}

extension Date {
    func toDay() -> Date {
        let dateFormatter = DateFormatter.day()
        let dayString = dateFormatter.string(from: self)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: dayString)!
    }
    
    func nextDay() -> Date {
        Calendar.current.date(byAdding: .day, value: +1, to: toDay())!.toDay()
    }
    
    static func today() -> Date {
        Date().toDay()
        
    }
    static func yesterday() -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: today())!.toDay()
    }
}
