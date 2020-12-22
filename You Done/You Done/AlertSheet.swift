//
//  AlertSheetView.swift
//  You Done
//
//  Created by Piotr Galar on 21/12/2020.
//

import SwiftUI

class AlertContext: ObservableObject {
    @Published var message: String?
}

struct AlertSheet: ViewModifier {
    @EnvironmentObject var alertContext: AlertContext

    func body(content: Content) -> some View {
        content.sheet(item: $alertContext.message) { msg in
            VStack {
                HStack {
                    Text(msg)
                }.padding()
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { alertContext.message = nil }) {
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
}
