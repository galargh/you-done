//
//  ConfigurationView.swift
//  You Done
//
//  Created by Piotr Galar on 13/12/2020.
//

import SwiftUI

struct ConfigurationView: View {
    @EnvironmentObject var colourScheme: ColourScheme
    @State var backgroundPull = true
    
    var body: some View {
        VStack(alignment: .leading) {
            Section(
                header: HStack {
                    Text("Status").bold()
                }
            ) {
                HStack {
                    Text("Background Pull").frame(minWidth: 150, alignment: .leading)
                    Button(action: { backgroundPull.toggle() }, label: {
                        Image(backgroundPull ? "Check Mark Colour" : "Cancel Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                    } ).buttonStyle(PlainButtonStyle())
                }.padding(.leading)
            }
            Section(
                header: HStack {
                    Text("Colour Scheme").bold()
                }
            ) {
                Picker(selection: Binding(
                    get: { return self.colourScheme.headerBackground },
                    set: { self.colourScheme.headerBackground = $0 }
                ), label: Text("Header Background").frame(minWidth: 150, alignment: .leading)) {
                    ForEach(Constants.Colours, id: \.self.description) { colour in
                        Rectangle().fill(colour).tag(colour)
                    }
                }//.pickerStyle(SegmentedPickerStyle())
                .padding(.leading)
                Picker(selection: Binding(
                    get: { return self.colourScheme.headerText },
                    set: { self.colourScheme.headerText = $0 }
                ), label: Text("Header Text").frame(minWidth: 150, alignment: .leading)) {
                    ForEach(Constants.Colours, id: \.self.description) { colour in
                        Rectangle().fill(colour).tag(colour)
                    }
                }//.pickerStyle(SegmentedPickerStyle())
                .padding(.leading)
                Picker(selection: Binding(
                    get: { return self.colourScheme.bodyBackground },
                    set: { self.colourScheme.bodyBackground = $0 }
                ), label: Text("Body Background").frame(minWidth: 150, alignment: .leading)) {
                    ForEach(Constants.Colours, id: \.self.description) { colour in
                        Rectangle().fill(colour).tag(colour)
                    }
                }//.pickerStyle(SegmentedPickerStyle())
                .padding(.leading)
                Picker(selection: Binding(
                    get: { return self.colourScheme.bodyText },
                    set: { self.colourScheme.bodyText = $0 }
                ), label: Text("Body Text").frame(minWidth: 150, alignment: .leading)) {
                    ForEach(Constants.Colours, id: \.self.description) { colour in
                        Rectangle().fill(colour).tag(colour)
                    }
                }//.pickerStyle(SegmentedPickerStyle())
                .padding(.leading)
            }
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(colourScheme.bodyBackground).padding()
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView()
    }
}
/*
 
 HStack {
     Button(action: { print("tap") }, label: {
         Image("Cancel Colour")
             .resizable()
             .aspectRatio(contentMode: .fit)
             .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
     } ).buttonStyle(PlainButtonStyle())
     Text("Commit Pushes")
     Spacer()
 }
 */
