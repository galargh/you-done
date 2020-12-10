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
    @State var tab: Int = 0
    
    var body: some View {
        ZStack {
            VStack {
                Text("You done")
                TabView(selection: $tab) {
                    StatusView().tabItem {
                        Text("Status")
                    }.tag(0).onAppear() { tab = 0 }
                    IntegrationListView(integrationName: $integrationName).tabItem {
                        Text("Integrations")
                    }.tag(1).onAppear() { tab = 1 }
                }
            }
            ForEach(integrationStore.all) { integration in
                IntegrationConfigurationView(integrationName: $integrationName, integration: integration)
                    .visibility(hidden: .constant(integration.name != integrationName))
                    .onReceive(integration.$isInstalled, perform: { _ in integrationStore.objectWillChange.send() })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
