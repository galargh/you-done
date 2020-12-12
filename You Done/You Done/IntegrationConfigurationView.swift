//
//  IntegrationView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct IntegrationConfigurationView: View {
    @EnvironmentObject var colourScheme: ColourScheme
    @Binding var integrationName: String?
    @State var path: String = ""
    var integration: Integration
    
    var body: some View {
        VStack {
            HStack {
                Text(integration.name).bold()
                Spacer()
            }
            VStack {
                HStack {
                    Button(action: { print("tap") }, label: {
                        Image("Check Mark Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                    } ).buttonStyle(PlainButtonStyle())
                    Text("Opened Pull Requests")
                    Spacer()
                }
                HStack {
                    Button(action: { print("tap") }, label: {
                        Image("Check Mark Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                    } ).buttonStyle(PlainButtonStyle())
                    Text("Closed Pull Requests")
                    Spacer()
                }
                HStack {
                    Button(action: { print("tap") }, label: {
                        Image("Check Mark Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                    } ).buttonStyle(PlainButtonStyle())
                    Text("Pull Request Reviews")
                    Spacer()
                }
                HStack {
                    Button(action: { print("tap") }, label: {
                        Image("Cancel Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.ButtonWidth, height: Constants.ButtonHeight)
                    } ).buttonStyle(PlainButtonStyle())
                    Text("Commit Pushes")
                    Spacer()
                }
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
                }.visibility(hidden: .constant(true))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(colourScheme.bodyBackground).padding()
    }
}
