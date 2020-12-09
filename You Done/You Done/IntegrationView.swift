//
//  IntegrationView.swift
//  You Done
//
//  Created by Piotr Galar on 08/12/2020.
//

import SwiftUI

struct IntegrationView: View {
    @Binding var integrationName: String?
    var integration: Integration
    
    var body: some View {
        VStack {
            Text(integration.name).onTapGesture {
                integrationName = nil
            }
        }
        .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
