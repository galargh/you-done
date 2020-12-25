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
    @EnvironmentObject var alertContext: AlertContext
    
    var body: some View {
        HStack {
            Text(integration.name)
            Spacer()
            if (integration.state == .installed) {
                Button(action: { integrationName = integration.name }, label: {
                    Image("Gears Colour")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: Constants.ShadowRadius)
                        .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                } ).buttonStyle(PlainButtonStyle()).padding(.leading, Constants.ButtonLeadingPadding)
            } else if (integration.state == .available) {
                Button(action: {
                    integration.oauth2.authorizeEmbedded(from: NSApp.windows[1]) { authParameters, error in
                        if authParameters != nil {
                            integration.isInstalled = true
                            alertContext.message = "Congratulations! You're all set!"
                        } else {
                            alertContext.message = "Authorization was canceled or went wrong: \(error!.localizedDescription)"
                        }
                    }
                }, label: {
                    Image(integration.oauth2.isAuthorizing ? "Download" : "Download Colour")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: Constants.ShadowRadius)
                        .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                } ).disabled(integration.oauth2.isAuthorizing).buttonStyle(PlainButtonStyle()).padding(.leading, Constants.ButtonLeadingPadding)
            } else {
                Button(action: {}) {}.visibility(hidden: .constant(true))
            }
        }.onReceive(publisher) { notification in
            if let url = notification.object as? URL {
                if url.lastPathComponent == integration.name {
                    do {
                        try integration.oauth2.handleRedirectURL(url)
                    } catch let error {
                        alertContext.message = "Authorization failed during redirect handling: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}
