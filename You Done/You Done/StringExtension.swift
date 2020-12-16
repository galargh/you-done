//
//  StringExtension.swift
//  You Done
//
//  Created by Piotr Galar on 16/12/2020.
//

import Foundation

extension String {
    func firstMatch(of pattern: String, with options: NSRegularExpression.MatchingOptions = []) -> NSTextCheckingResult? {
        let range = NSRange(location: 0, length: self.utf16.count)
        let regex = try! NSRegularExpression(pattern: pattern)
        return regex.firstMatch(in: self, options: options, range: range)
    }
    
    func firstMatch(of pattern: String, options: NSRegularExpression.MatchingOptions = [], as template: String) -> String? {
        var result: String = template
        guard let patternMatch = self.firstMatch(of: pattern, with: options) else { return nil }
        while let templateMatch = result.firstMatch(of: "\\$([a-zA-Z0-9]+)") {
            print(templateMatch)
            let key = String(result[Range(templateMatch.range(at: 1), in: result)!])
            var patternRange: NSRange
            if let idx = Int(key) {
                patternRange = patternMatch.range(at: idx)
            } else {
                patternRange = patternMatch.range(withName: key)
            }
            guard let range = Range(patternRange, in: self) else { return nil }
            result.replaceSubrange(Range(templateMatch.range, in: result)!, with: String(self[range]))
        }
        return result
    }
}
