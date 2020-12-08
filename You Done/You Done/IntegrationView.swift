//
//  IntegrationView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct IntegrationView: View {
    var integration: Integration
    
    var body: some View {
        StackNavigationResetView {
            Text(integration.name)
        }.frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct IntegrationView_Previews: PreviewProvider {
    static var previews: some View {
        IntegrationView(integration: Integration(name: "GitHub", state: .installed))
    }
}
