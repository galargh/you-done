//
//  ContentView.swift
//  You Done
//
//  Created by Piotr Galar on 07/12/2020.
//

import SwiftUI

struct ContentView: View {
    @State var integrationName: String?
    var integrationList: [Integration] = [GithubIntegration(), SlackIntegration(), GoogleCalendarIntegration(), ZoomIntegration()]
    var body: some View {
        ZStack {
            VStack {
                Text("You done")
                TabView {
                    StatusView().tabItem {
                        Text("Status")
                    }
                    IntegrationListView(integrationName: $integrationName, integrationList: integrationList).tabItem {
                        Text("Integrations")
                    }
                }
            }
            ForEach(integrationList) { integration in
                IntegrationView(integrationName: $integrationName, integration: integration)
                    .visibility(hidden: .constant(integration.name != integrationName))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
