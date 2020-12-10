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
                                    Button(action: {
                                        integration.oauth2.authorize {
                                        //integration.oauth2.authorizeEmbedded(from: NSApp.windows[1]) { // doesn't work with .transient
                                            authParameters, error in
                                                if let params = authParameters {
                                                    print("Authorized! Access token is in `oauth2.accessToken`")
                                                    print(integration.oauth2.accessToken)
                                                    print("Authorized! Additional parameters: \(params)")
                                                }
                                                else {
                                                    print("Authorization was canceled or went wrong: \(error)")   // error will not be nil
                                                }
                                        }
                                    }, label: { Text("Install") } ).disabled(integration.oauth2.isAuthorizing)
                                }
                            }
                        }
                    }.collapsible(true)
                }
            }
        }.listStyle(SidebarListStyle())
    }
}
