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
    @ObservedObject var integration: Integration
    
    var body: some View {
        VStack {
            HStack {
                Text(integration.name).bold()
                Spacer()
            }
            VStack {
                ForEach(integration.eventConfigurationList, id: \.name) { eventConfiguration in
                    EventConfigurationView(eventConfiguration: eventConfiguration)
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        integration.oauth2.forgetTokens()
                        integration.isInstalled = false
                        integrationName = nil
                    }, label: {
                        Image("Dump Colour")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.BigButtonWidth, height: Constants.BigButtonHeight)
                            .shadow(radius: Constants.BigShadowRadius)
                    } ).buttonStyle(PlainButtonStyle())
                }
            }.padding(.leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(colourScheme.bodyBackground).padding()
    }
}
