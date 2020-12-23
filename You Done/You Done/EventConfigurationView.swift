//
//  EventConfigurationView.swift
//  You Done
//
//  Created by Piotr Galar on 16/12/2020.
//

import SwiftUI

class WrapperContext {
    var geometry: GeometryProxy
    var width: CGFloat = .zero
    var height: CGFloat = .zero
    var leading: CGFloat = 20
    var vertical: CGFloat = 1
    var horizontal: CGFloat = 1
    
    init(geometry: GeometryProxy) {
        self.geometry = geometry
    }
}

struct Wrapper: ViewModifier {
    var context: WrapperContext
    var last: Bool = false
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, context.vertical)
            .padding(.horizontal, context.horizontal)
            .fixedSize()
            .alignmentGuide(.leading, computeValue: { d in
                if (context.width + ceil(d.width) > context.geometry.size.width) {
                    context.width = context.leading
                    context.height += d.height
                }
                let result = -context.width
                if last {
                    context.width = 0
                } else {
                    context.width += ceil(d.width)
                }
                return result
            })
            .alignmentGuide(.top, computeValue: { d in
                let result = -context.height
                if last {
                    context.height = 0
                }
                return result
            })
    }
}

struct EventConfigurationView: View {
    @EnvironmentObject var colourScheme: ColourScheme
    @ObservedObject var eventConfiguration: EventConfiguration
    @State private var totalHeight = CGFloat.zero
    
    @EnvironmentObject var alertContext: AlertContext
    
    var body: some View {
        HStack {
            GeometryReader { g in
                let context = WrapperContext(geometry: g)
                let vertical = CGFloat(5)
                let horizontal = CGFloat(5)
                let commit = {
                    do {
                        try eventConfiguration.validate()
                        eventConfiguration.commit()
                    } catch let error {
                        print(error)
                        // alertContext.message = error.localizedDescription
                    }
                }
                ZStack(alignment: .topLeading) {
                    Text("If")
                        .padding(.vertical, vertical)
                        .modifier(Wrapper(context: context))
                    (Text(eventConfiguration.name).bold() + Text("'s \(eventConfiguration.field)"))
                        .padding(.vertical, vertical)
                        .modifier(Wrapper(context: context))
                    Text("matches")
                        .padding(.vertical, vertical)
                        .modifier(Wrapper(context: context))
                    HStack {
                        TextField("", text: $eventConfiguration.pattern, onCommit: commit)
                            .textFieldStyle(PlainTextFieldStyle()).colorMultiply(colourScheme.headerText)
                        if (!eventConfiguration.isPatternValid) {
                            Image("Caution Colour")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16.0, height: 16.0)
                        }
                    }
                        .padding(.vertical, vertical)
                        .padding(.horizontal, horizontal)
                        .background(colourScheme.headerBackground)
                        .foregroundColor(colourScheme.headerText)
                        .frame(maxWidth: g.size.width - context.leading)
                        .modifier(Wrapper(context: context))
                    Text("create")
                        .padding(.vertical, vertical)
                        .modifier(Wrapper(context: context))
                    HStack {
                        TextField("", text: $eventConfiguration.template, onCommit: commit)
                            .textFieldStyle(PlainTextFieldStyle()).colorMultiply(colourScheme.headerText)
                        if (!eventConfiguration.isTemplateValid) {
                            Image("Caution Colour")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16.0, height: 16.0)
                        }
                    }
                        .padding(.vertical, vertical)
                        .padding(.horizontal, horizontal)
                        .background(colourScheme.headerBackground)
                        .foregroundColor(colourScheme.headerText)
                        .frame(maxWidth: g.size.width - context.leading)
                        .modifier(Wrapper(context: context, last: true))
                }.background(viewHeightReader($totalHeight))
                Spacer()
            }
        }.frame(height: totalHeight)
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>, colour: Color = .clear) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return colour
        }
    }
}
