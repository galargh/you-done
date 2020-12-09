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
            ForEach(Integration.State.allCases, id: \.rawValue) { state in
                if let availableIntegrationList = integrationListByStateValue[state] {
                    Section(header: Text(state.rawValue)) {
                        ForEach(availableIntegrationList) { integration in
                            HStack {
                                Text(integration.name)
                                Spacer()
                                if (integration.state == .installed) {
                                    Button(action: { integrationName = integration.name }, label: { Text("Configure") } )
                                } else if (integration.state == .available) {
                                    Button(action: { print("Install") }, label: { Text("Install") } )
                                }
                            }
                        }
                    }.collapsible(true)
                }
            }
        }.listStyle(SidebarListStyle())
    }
}
