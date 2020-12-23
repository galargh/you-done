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
    @State var showDeleted: Bool = false
    
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
                            if (!configure && !showDeleted && integrationName == nil) { configure = true }
                            else {
                                configure = false
                                integrationName = nil
                                showDeleted = false
                            }
                        }) {
                            Image((!configure && !showDeleted && integrationName == nil) ? "Gears Colour" : "Turn Back Colour")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                                .shadow(radius: Constants.BigShadowRadius)
                        }.buttonStyle(PlainButtonStyle()).padding(.leading, Constants.BigButtonLeadingPadding)
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
                        StatusView(showDeleted: $showDeleted).padding()
                    } else if (tab == "integrations") {
                        IntegrationListView(integrationName: $integrationName).padding()
                    }
                    ForEach(integrationStore.all) { integration in
                        IntegrationConfigurationView(integrationName: $integrationName, integration: integration)
                            .visibility(hidden: .constant(integration.name != integrationName))
                            .onReceive(integration.$isInstalled, perform: { _ in integrationStore.objectWillChange.send() })
                    }
                    ConfigurationView().visibility(hidden: .constant(!configure))
                }.background(colourScheme.bodyBackground).foregroundColor(colourScheme.bodyText)
            }
        }.background(colourScheme.headerBackground).foregroundColor(colourScheme.headerText).modifier(AlertSheet())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
