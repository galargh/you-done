//
//  StackNavigationView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct StackNavigationEventKey: PreferenceKey {
    static var defaultValue: StackNavigationEvent?

    static func reduce(value: inout StackNavigationEvent?, nextValue: () -> StackNavigationEvent?) {
        if (nextValue() != defaultValue) {
            value = nextValue()
        }
    }
}

struct StackNavigationEvent: Equatable, Identifiable {
    static let Reset = StackNavigationEvent(view: nil)
    
    let id = UUID()
    let view: AnyView?
    
    static func == (lhs: StackNavigationEvent, rhs: StackNavigationEvent) -> Bool {
        return lhs.id == rhs.id
    }
}

struct StackNavigationView<Content: View>: View {
    @State private var viewOpt: AnyView?
    
    var content: () -> Content
  
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
      
    var body: some View {
        AnyView(
            VStack {
                if let view = viewOpt {
                    view
                } else {
                    content()
                }
            }
            .onPreferenceChange(StackNavigationEventKey.self) {
                if let event = $0 {
                    viewOpt = event.view
                }
            }
        )
    }
}

struct StackNavigationResetView<Label: View>: View {
    @State private var event: StackNavigationEvent?
    
    var label: () -> Label
  
    init(@ViewBuilder label: @escaping () -> Label) {
        self.label = label
    }
      
    var body: some View {
        Button(action: { event = StackNavigationEvent.Reset }) {
            label()
        }
        .preference(key: StackNavigationEventKey.self, value: event)
    }
}

struct StackNavigationLinkView<Label: View, Destination: View>: View {
    @State private var event: StackNavigationEvent?
    
    var destination: AnyView
    var label: () -> Label
    
    init(destination: Destination, @ViewBuilder label: @escaping () -> Label) {
        self.destination = AnyView(destination)
        self.label = label
    }

    var body: some View {
        Button(action: { event = StackNavigationEvent(view: destination) }) {
            label()
        }
        .preference(key: StackNavigationEventKey.self, value: event)
    }
}
