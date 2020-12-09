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
            ForEach(Integration.State.allCases, id: \.rawValue) { key in
                if let integrationListForKey = integrationListByStateValue[key] {
                    Section(header: Text(key.rawValue)) {
                        ForEach(integrationListForKey) { integration in
                            Text(integration.name).onTapGesture {
                                integrationName = integration.name
                            }
                        }
                    }.collapsible(true)
                }
            }
        }.listStyle(SidebarListStyle())
    }
}
