//
//  StringDefaultView.swift
//  You Done
//
//  Created by Piotr Galar on 16/12/2020.
//

import SwiftUI

struct StringDefaultView: View {
    var key: String
    @State var value: String
    
    var body: some View {
        HStack {
            Text(key).frame(minWidth: 150, alignment: .leading)
            TextField(
                "",
                text: $value,
                onCommit: {
                    UserDefaults.standard.setValue(value, forKey: key)
                }
            ).textFieldStyle(PlainTextFieldStyle())
        }
    }
}
