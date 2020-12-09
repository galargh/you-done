//
//  IntegrationListView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI


struct IntegrationListView: View {
    @Binding var integrationName: String?
    var integrationList: [Integration]
    var integrationListByStateValue: [Integration.State: [Integration]] {
        Dictionary(
            grouping: integrationList,
            by: { $0.state }
        )
    }

    var body: some View {
        List {
            if let installedIntegrationList = integrationListByStateValue[.installed] {
                Section(header: Text("Installed")) {
                    ForEach(installedIntegrationList) { integration in
                        HStack {
                            Text(integration.name)
                            Spacer()
                            Button(action: { integrationName = integration.name }, label: { Text("Configure") } )
                        }
                    }
                }.collapsible(true)
            }
            if let availableIntegrationList = integrationListByStateValue[.available] {
                Section(header: Text("Available")) {
                    ForEach(availableIntegrationList) { integration in
                        HStack {
                            Text(integration.name)
                            Spacer()
                            Button(action: { print("Install") }, label: { Text("Install") } )
                        }
                    }
                }.collapsible(true)
            }
        }.listStyle(SidebarListStyle())
    }
}
