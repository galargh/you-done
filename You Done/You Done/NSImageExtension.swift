//
//  NSImageExtension.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import Cocoa

extension NSImage {
    func resize(toSize targetSize: NSSize) -> NSImage? {
        let frame = NSRect(origin: .zero, size: targetSize)
        if let representation = self.bestRepresentation(for: frame, context: nil, hints: nil) {
            return NSImage(size: targetSize, flipped: false, drawingHandler: { (_) -> Bool in
                return representation.draw(in: frame)
            })
        } else {
            return nil
        }
    }
}
