//
//  ContentView.swift
//  You Done
//
//  Created by Piotr Galar on 07/12/2020.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        StackNavigationView {
            VStack {
                Text("You done")
                TabView {
                    StatusView().tabItem {
                        Text("Status")
                    }
                    IntegrationListView().tabItem {
                        Text("Integrations")
                    }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
