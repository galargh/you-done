//
//  ContentView.swift
//  You Done
//
//  Created by Piotr Galar on 07/12/2020.
//

import SwiftUI

struct ContentView: View {
    @State var integrationName: String?
    @EnvironmentObject var integrationStore: IntegrationStore
    @EnvironmentObject var colourScheme: ColourScheme
    @State var tab: String = "status"
    @State var configure: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    HStack() {
                        HStack(alignment: .bottom) {
                            Image("Cupcake Colour")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 48.0, height: 48.0)
                            Text("You done!").font(.system(size: 32.0)).fontWeight(.bold)
                        }
                        Spacer()
                        Button(action: {
                            if (!configure && integrationName == nil) { configure = true }
                            else {
                                configure = false
                                integrationName = nil
                            }
                        }) {
                            Image((!configure && integrationName == nil) ? "Gears Colour" : "Stick Colour")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                        }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.ButtonLeadingPadding)
                    }.padding()
                    HStack {
                        Button(action: { tab = "status" }) {
                            Text("Status").foregroundColor(colourScheme.headerText).underline(tab == "status").bold(tab == "status")
                        }.buttonStyle(PlainButtonStyle())
                        Button(action: { tab = "integrations" }) {
                            Text("Integrations").foregroundColor(colourScheme.headerText).underline(tab == "integrations").bold(tab == "integrations")
                        }.buttonStyle(PlainButtonStyle())
                        Spacer()
                    }.padding(.leading).visibility(hidden: .constant(configure || integrationName != nil))
                }
                ZStack {
                    if (tab == "status") {
                        StatusView().padding()
                    } else if (tab == "integrations") {
                        IntegrationListView(integrationName: $integrationName).padding()
                    }
                    ForEach(integrationStore.all) { integration in
                        IntegrationConfigurationView(integrationName: $integrationName, integration: integration)
                            .visibility(hidden: .constant(integration.name != integrationName))
                            .onReceive(integration.$isInstalled, perform: { _ in integrationStore.objectWillChange.send() })
                    }
                    ZStack {
                        VStack(alignment: .leading) {
                            Picker(selection: Binding(
                                get: { return self.colourScheme.headerBackground },
                                set: { self.colourScheme.headerBackground = $0 }
                            ), label: Text("Header Background").frame(minWidth: 150, alignment: .leading)) {
                                ForEach(Constants.Colours, id: \.self.description) { colour in
                                    Rectangle().fill(colour).tag(colour)
                                }
                            }//.pickerStyle(SegmentedPickerStyle())
                            Picker(selection: Binding(
                                get: { return self.colourScheme.headerText },
                                set: { self.colourScheme.headerText = $0 }
                            ), label: Text("Header Text").frame(minWidth: 150, alignment: .leading)) {
                                ForEach(Constants.Colours, id: \.self.description) { colour in
                                    Rectangle().fill(colour).tag(colour)
                                }
                            }//.pickerStyle(SegmentedPickerStyle())
                            Picker(selection: Binding(
                                get: { return self.colourScheme.bodyBackground },
                                set: { self.colourScheme.bodyBackground = $0 }
                            ), label: Text("Body Background").frame(minWidth: 150, alignment: .leading)) {
                                ForEach(Constants.Colours, id: \.self.description) { colour in
                                    Rectangle().fill(colour).tag(colour)
                                }
                            }//.pickerStyle(SegmentedPickerStyle())
                            Picker(selection: Binding(
                                get: { return self.colourScheme.bodyText },
                                set: { self.colourScheme.bodyText = $0 }
                            ), label: Text("Body Text").frame(minWidth: 150, alignment: .leading)) {
                                ForEach(Constants.Colours, id: \.self.description) { colour in
                                    Rectangle().fill(colour).tag(colour)
                                }
                            }//.pickerStyle(SegmentedPickerStyle())
                            Spacer()
                        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(colourScheme.bodyBackground).padding()
                    }.visibility(hidden: .constant(!configure))
                }.background(colourScheme.bodyBackground).foregroundColor(colourScheme.bodyText)
            }
        }.background(colourScheme.headerBackground).foregroundColor(colourScheme.headerText)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
