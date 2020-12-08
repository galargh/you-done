//
//  IntegrationListView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI


struct IntegrationListView: View {
    var integrationList: [Integration] = [
        Integration(name: "GitHub", state: .installed),
        Integration(name: "Google Calendar", state: .installed),
        Integration(name: "Slack", state: .available),
        Integration(name: "Zoom", state: .available)
    ]
    var integrationListByStateValue: [Integration.State: [Integration]] {
        Dictionary(
            grouping: integrationList,
            by: { $0.state }
        )
    }

    var body: some View {
        List {
            ForEach(Integration.State.allCases, id: \.rawValue) { key in
                if let integrationListForKey = integrationListByStateValue[key] {
                    Section(header: Text(key.rawValue)) {
                        ForEach(integrationListForKey) { integration in
                            StackNavigationLinkView(destination: IntegrationView(integration: integration)) {
                                Text(integration.name)
                            }
                        }
                    }.collapsible(true)
                }
            }
        }.listStyle(SidebarListStyle())
    }
}

struct IntegrationListView_Previews: PreviewProvider {
    static var previews: some View {
        IntegrationListView()
    }
}
