//
//  EventMonitor.swift
//  You Done
//
//  Created by Piotr Galar on 09/12/2020.
//

import Foundation
import Cocoa

class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> NSEvent?
    
    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> NSEvent?) {
      self.mask = mask
      self.handler = handler
    }

    deinit {
      stop()
    }

    public func start() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler) as! NSObject
    }

    public func stop() {
      if monitor != nil {
        NSEvent.removeMonitor(monitor!)
        monitor = nil
      }
    }
}
