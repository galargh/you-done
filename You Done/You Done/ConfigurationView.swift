//
//  ConfigurationView.swift
//  You Done
//
//  Created by Piotr Galar on 13/12/2020.
//

import SwiftUI

struct ConfigurationView: View {
    @EnvironmentObject var colourScheme: ColourScheme
    @State var activePull = UserDefaults.standard.bool(forKey: "Active Pull")
    
    var body: some View {
        VStack(alignment: .leading) {
            Section(
                header: HStack {
                    Text("Status").bold()
                }
            ) {
                HStack {
                    Text("Active Pull").frame(minWidth: 150, alignment: .leading)
                    Button(action: {
                        activePull.toggle()
                        UserDefaults.standard.setValue(activePull, forKey: "Active Pull")
                    }, label: {
                        Image(activePull ? "Check Mark Colour" : "Cancel Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: Constants.ShadowRadius)
                            .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                    } ).buttonStyle(PlainButtonStyle())
                }.padding(.leading)
            }
            Section(
                header: HStack {
                    Text("Colour Scheme").bold()
                }
            ) {
                HStack {
                    Text("Header Background").frame(minWidth: 150, alignment: .leading)
                    ColourPickerView(colour: $colourScheme.headerBackground, onPick: { _ in colourScheme.commitHeaderBackground() })
                }.padding(.leading)
                HStack {
                    Text("Header Colour").frame(minWidth: 150, alignment: .leading)
                    ColourPickerView(colour: $colourScheme.headerText, onPick: { _ in colourScheme.commitHeaderText() })
                }.padding(.leading)
                HStack {
                    Text("Body Background").frame(minWidth: 150, alignment: .leading)
                    ColourPickerView(colour: $colourScheme.bodyBackground, onPick: { _ in colourScheme.commitBodyBackground() })
                }.padding(.leading)
                HStack {
                    Text("Body Test").frame(minWidth: 150, alignment: .leading)
                    ColourPickerView(colour: $colourScheme.bodyText, onPick: { _ in colourScheme.commitBodyText() })
                }.padding(.leading)
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    NSApp.terminate(nil)
                }, label: {
                    Image("Exit Colour")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: Constants.BigShadowRadius)
                        .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                } ).buttonStyle(PlainButtonStyle())
            }
        }.padding().frame(maxWidth: .infinity, maxHeight: .infinity).background(colourScheme.bodyBackground)
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView()
    }
}
