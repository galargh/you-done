//
//  IntegrationListView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct IntegrationListView: View {
    @Binding var integrationName: String?
    @EnvironmentObject var integrationStore: IntegrationStore

    var body: some View {
        List {
            ForEach(Integration.State.allCases, id: \.rawValue) { state in
                let integrationList = integrationStore.all(forState: state)
                if !integrationList.isEmpty {
                    Section(header: Text(state.rawValue)) {
                        ForEach(integrationList) { integration in
                            IntegrationView(integration: integration, integrationName: _integrationName)
                                .onReceive(integration.$isInstalled, perform: { _ in integrationStore.objectWillChange.send() })
                        }
                    }.collapsible(true)
                }
            }
        }.listStyle(SidebarListStyle())
    }
}
