//
//  StringExtension.swift
//  You Done
//
//  Created by Piotr Galar on 16/12/2020.
//

import Foundation

extension NSRegularExpression {
    static let forGroupInPattern = try! NSRegularExpression(pattern: "\\?<([a-zA-Z][a-zA-Z0-9]*)>")
    static let forGroupInTemplate = try! NSRegularExpression(pattern: "\\$([a-zA-Z][a-zA-Z0-9]*|\\{[a-zA-Z][a-zA-Z0-9]*\\}|[0-9]+|\\{[0-9]+\\})")
}

extension String: Identifiable {
    public var id: String { self }
    
    
}

extension String {
    func firstMatch(of pattern: String, with options: NSRegularExpression.MatchingOptions = []) throws -> NSTextCheckingResult? {
        let range = NSRange(location: 0, length: self.utf16.count)
        let regex = try NSRegularExpression(pattern: pattern)
        return regex.firstMatch(in: self, options: options, range: range)
    }
    
    func matches(of pattern: String, with options: NSRegularExpression.MatchingOptions = []) throws -> [NSTextCheckingResult] {
        let range = NSRange(location: 0, length: self.utf16.count)
        let regex = try NSRegularExpression(pattern: pattern)
        return regex.matches(in: self, options: options, range: range)
    }
    
    func firstMatch(of pattern: String, options: NSRegularExpression.MatchingOptions = [], as template: String) throws -> String? {
        var result: String = template
        guard let patternMatch = try self.firstMatch(of: pattern, with: options) else { return nil }
        while let templateMatch = try result.firstMatch(of: NSRegularExpression.forGroupInTemplate.pattern) {
            var key = String(result[Range(templateMatch.range(at: 1), in: result)!])
            key.removeAll(where: { ["{", "}"].contains($0) })
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
