//
//  IntegrationView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct IntegrationConfigurationView: View {
    @Binding var integrationName: String?
    var integration: Integration
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { integrationName = nil }) {
                    Text("Go back")
                }
                Spacer()
            }
            HStack {
                Text(integration.name)
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        integration.oauth2.forgetTokens()
                        integration.isInstalled = false
                        integrationName = nil
                    }) {
                        Text("Uninstall")
                    }
                }
            }
        }
        .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
