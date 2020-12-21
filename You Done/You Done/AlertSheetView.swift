//
//  AlertSheetView.swift
//  You Done
//
//  Created by Piotr Galar on 21/12/2020.
//

import SwiftUI

struct AlertSheet: ViewModifier {
    @Binding var alert: String?
    
    func body(content: Content) -> some View {
        content.sheet(isPresented: .constant(alert != nil)) { AlertSheetView(alert: _alert) }
    }
}

struct AlertSheetView: View {
    @Binding var alert: String?
    
    var body: some View {
        VStack {
            HStack {
                Text(alert ?? "Unknown error")
                    .lineLimit(nil)
            }.padding()
            Spacer()
            HStack {
                Spacer()
                Button(action: { alert = nil }) {
                    Image("Check Mark Colour")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                }
                .buttonStyle(PlainButtonStyle())
            }.padding()
        }.frame(width: 500, height: 200)
    }
}
