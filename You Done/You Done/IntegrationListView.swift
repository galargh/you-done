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
        ScrollView {
            ForEach(Integration.State.allCases, id: \.rawValue) { state in
                let integrationList = integrationStore.all(forState: state)
                if !integrationList.isEmpty {
                    Section(
                        header: HStack {
                            Text(state.rawValue).bold()
                            Spacer()
                        }
                    ) {
                        ForEach(integrationList) { integration in
                            IntegrationView(integration: integration, integrationName: _integrationName)
                                .onReceive(integration.$isInstalled, perform: { _ in integrationStore.objectWillChange.send() }).padding(.leading).frame(minHeight: Constants.ButtonHeight)
                        }
                    }.collapsible(true)
                }
            }
            Spacer()
            
        }
    }
}
