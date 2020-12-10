//
//  IntegrationView.swift
//  You Done
//
//  Created by Piotr Galar on 10/12/2020.
//

import SwiftUI

struct IntegrationView: View {
    private let publisher = NotificationCenter.default.publisher(for: Integration.Notification)
    
    @ObservedObject var integration: Integration
    @Binding var integrationName: String?    
    
    var body: some View {
        HStack {
            Text(integration.name)
            Spacer()
            Text(integration.state.rawValue)
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
                                integration.isInstalled = true
                            } else {
                                print("Authorization was canceled or went wrong: \(error)")   // error will not be nil
                            }
                    }
                }, label: { Text("Install") } ).disabled(integration.oauth2.isAuthorizing)
            }
        }.onReceive(publisher) { notification in
            if let url = notification.object as? URL {
                if url.lastPathComponent == integration.name {
                    do {
                        print("Handling \(url) in \(integration.name)")
                        try integration.oauth2.handleRedirectURL(url)
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
    }
}
