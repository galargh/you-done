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
    
    var body: some View {
        ZStack {
            VStack {
                Text("You done")
                TabView {
                    StatusView().tabItem {
                        Text("Status")
                    }
                    IntegrationListView(integrationName: $integrationName).tabItem {
                        Text("Integrations")
                    }
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
